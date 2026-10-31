import Foundation
import MyspotiDomain

/// Async/await HTTP client handling authentication headers and error mapping.
public actor HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Executes an HTTP request and decodes the response body into Decodable T.
    public func execute<T: Decodable>(
        request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response format received.")
        }

        try validate(response: httpResponse, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    /// Executes an HTTP request with no expected return body (e.g. 204 No Content for play/pause).
    public func executeVoid(request: URLRequest) async throws {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response format received.")
        }

        try validate(response: httpResponse, data: data)
    }

    private func validate(response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            let reason = parseSpotifyErrorReason(data: data) ?? "PREMIUM_REQUIRED"
            throw NetworkError.forbidden(reason: reason)
        case 404:
            throw NetworkError.notFound
        case 429:
            let retryAfterStr = response.value(forHTTPHeaderField: "Retry-After") ?? "5"
            let retrySeconds = Int(retryAfterStr) ?? 5
            throw NetworkError.rateLimited(retryAfterSeconds: retrySeconds)
        case 500...599:
            throw NetworkError.serverError(statusCode: response.statusCode)
        default:
            let msg = String(data: data, encoding: .utf8) ?? "HTTP \(response.statusCode)"
            throw NetworkError.unknown(msg)
        }
    }

    private func parseSpotifyErrorReason(data: Data) -> String? {
        struct SpotifyErrorEnvelope: Decodable {
            struct SpotifyError: Decodable {
                let message: String?
                let reason: String?
            }
            let error: SpotifyError?
        }

        let envelope = try? JSONDecoder().decode(SpotifyErrorEnvelope.self, from: data)
        return envelope?.error?.reason ?? envelope?.error?.message
    }
}

