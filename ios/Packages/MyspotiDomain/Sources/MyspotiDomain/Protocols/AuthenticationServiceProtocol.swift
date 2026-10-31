import Foundation

public enum AuthState: Equatable, Sendable {
    case unauthenticated
    case authenticating
    case authenticated(UserProfile)
    case error(String)
}

/// Defines OAuth 2.0 PKCE authentication contracts.
public protocol AuthenticationServiceProtocol: Sendable {
    /// Observes the current authentication state.
    func observeAuthState() -> AsyncStream<AuthState>

    /// Launches the OAuth 2.0 PKCE authorization flow via ASWebAuthenticationSession.
    func signIn() async throws -> UserProfile

    /// Attempts to silently restore the session using stored Keychain tokens.
    func restoreSession() async throws -> UserProfile?

    /// Refreshes the active access token using the stored refresh token.
    func refreshAccessToken() async throws -> String

    /// Clears tokens from Keychain and logs out.
    func signOut() async
}

