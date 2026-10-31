import Foundation

/// Strongly-typed network errors mapped from HTTP and Spotify API specifications.
public enum NetworkError: Error, LocalizedError, Sendable, Equatable {
    case invalidURL
    case unauthorized // HTTP 401: Token expired or invalid
    case forbidden(reason: String) // HTTP 403: E.g., PREMIUM_REQUIRED
    case notFound // HTTP 404: Device or track not found
    case rateLimited(retryAfterSeconds: Int) // HTTP 429
    case serverError(statusCode: Int)
    case decodingError(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .unauthorized:
            return "Session expired. Please sign in again."
        case .forbidden(let reason):
            if reason.localizedCaseInsensitiveContains("premium") {
                return "This action requires an active Spotify Premium subscription."
            }
            return "Access forbidden: \(reason)"
        case .notFound:
            return "Resource or active player device not found."
        case .rateLimited(let retryAfter):
            return "Rate limit exceeded. Please retry after \(retryAfter) seconds."
        case .serverError(let code):
            return "Spotify service error (HTTP \(code)). Please try again later."
        case .decodingError(let details):
            return "Failed to parse response: \(details)"
        case .unknown(let message):
            return message
        }
    }
}

