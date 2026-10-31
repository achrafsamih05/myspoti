import Foundation
import CryptoKit
import MyspotiDomain

/// Errors encountered during PKCE authorization or code exchange.
public enum PKCEError: Error, LocalizedError, Sendable, Equatable {
    case randomGenerationFailed(OSStatus)

    public var errorDescription: String? {
        switch self {
        case .randomGenerationFailed(let status):
            return "Failed to generate cryptographically secure random bytes (OSStatus \(status))."
        }
    }
}

/// Manages OAuth 2.0 Authorization Code Flow with PKCE (Proof Key for Code Exchange).
public final class PKCECoordinator: Sendable {
    public let clientId: String
    public let redirectURI: String

    public init(clientId: String, redirectURI: String = "myspoti://callback") {
        self.clientId = clientId
        self.redirectURI = redirectURI
    }

    /// Generates a high-entropy cryptographically random 32-byte string (43 characters when base64url-encoded).
    ///
    /// - Parameter randomBytesGenerator: Optional closure for generating random bytes. Defaults to `SecRandomCopyBytes`.
    /// - Returns: A base64url-encoded string of 32 random bytes without padding.
    /// - Throws: `PKCEError.randomGenerationFailed` if random number generation fails. Never falls back to predictable zeros.
    public func generateCodeVerifier(
        randomBytesGenerator: ((Int) -> Result<[UInt8], OSStatus>)? = nil
    ) throws -> String {
        let count = 32
        let result: Result<[UInt8], OSStatus>
        if let customGenerator = randomBytesGenerator {
            result = customGenerator(count)
        } else {
            var buffer = [UInt8](repeating: 0, count: count)
            let status = SecRandomCopyBytes(kSecRandomDefault, count, &buffer)
            if status == errSecSuccess {
                result = .success(buffer)
            } else {
                result = .failure(status)
            }
        }

        switch result {
        case .success(let bytes):
            return Data(bytes).base64URLEncodedString()
        case .failure(let status):
            throw PKCEError.randomGenerationFailed(status)
        }
    }

    /// Derives the S256 code_challenge from code_verifier using SHA-256.
    public func generateCodeChallenge(from verifier: String) -> String {
        let digest = SHA256.hash(data: Data(verifier.utf8))
        return Data(digest).base64URLEncodedString()
    }

    /// Constructs the authorization URL for ASWebAuthenticationSession using URLComponents.
    public func buildAuthorizeURL(codeChallenge: String, state: String) -> URL? {
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")
        let scopes = [
            "user-read-playback-state",
            "user-modify-playback-state",
            "user-read-currently-playing",
            "user-read-private",
            "user-read-email",
            "playlist-read-private",
            "playlist-read-collaborative",
            "playlist-modify-public",
            "playlist-modify-private",
            "user-library-read",
            "user-library-modify",
            "user-top-read",
            "user-read-recently-played",
            "user-follow-read",
            "user-follow-modify"
        ].joined(separator: " ")

        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "state", value: state)
        ]

        return components?.url
    }

    /// Encodes a dictionary of key-value pairs into `application/x-www-form-urlencoded` format according to
    /// RFC 1866 and WHATWG standards.
    /// Keys and values are percent-encoded with RFC 3986 unreserved characters (`a-z`, `A-Z`, `0-9`, `-`, `_`, `.`, `~`),
    /// spaces are converted to `+`, and pairs are sorted by key and joined by `&`.
    public static func formURLEncode(_ parameters: [String: String]) -> Data? {
        let encodedString = parameters
            .sorted(by: { $0.key < $1.key })
            .map { "\(encodeFormField($0.key))=\(encodeFormField($0.value))" }
            .joined(separator: "&")
        return encodedString.data(using: .utf8)
    }

    /// Encodes a single form field (key or value) for `application/x-www-form-urlencoded`.
    /// Spaces are converted to `+`, and reserved characters (including literal `+`, `=`, `&`, `:`, `/`) are percent-encoded.
    public static func encodeFormField(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.~")
        let percentEncoded = string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
        return percentEncoded.replacingOccurrences(of: "%20", with: "+")
    }

    /// Exchanges an authorization code and original code_verifier for access and refresh tokens.
    public func exchangeCodeForTokens(code: String, codeVerifier: String) async throws -> TokenResponse {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParameters: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientId,
            "code_verifier": codeVerifier
        ]

        guard let bodyData = Self.formURLEncode(bodyParameters) else {
            throw NetworkError.unknown("Failed to encode form-urlencoded request body")
        }
        request.httpBody = bodyData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Failed to exchange authorization code"
            throw NetworkError.unknown(msg)
        }

        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }

    /// Refreshes the access token using the refresh token.
    public func refreshAccessToken(refreshToken: String) async throws -> TokenResponse {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParameters: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientId
        ]

        guard let bodyData = Self.formURLEncode(bodyParameters) else {
            throw NetworkError.unknown("Failed to encode form-urlencoded request body")
        }
        request.httpBody = bodyData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.unauthorized
        }

        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }
}

public struct TokenResponse: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let refreshToken: String?
    public let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
