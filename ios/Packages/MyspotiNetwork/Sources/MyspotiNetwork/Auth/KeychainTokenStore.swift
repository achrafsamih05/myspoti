import Foundation
import Security

/// Thread-safe token storage backed by Apple Keychain Services.
public final class KeychainTokenStore: @unchecked Sendable {
    private let service: String
    private let accessKey = "app.myspoti.access_token"
    private let refreshKey = "app.myspoti.refresh_token"
    private let expiryKey = "app.myspoti.token_expiry"
    private let lock = NSLock()

    public init(service: String = "app.myspoti.auth") {
        self.service = service
    }

    public func saveTokens(accessToken: String, refreshToken: String?, expiresInSeconds: Int) {
        lock.lock()
        defer { lock.unlock() }

        save(key: accessKey, value: accessToken)
        if let refresh = refreshToken {
            save(key: refreshKey, value: refresh)
        }

        let expiryDate = Date().addingTimeInterval(TimeInterval(expiresInSeconds))
        let expiryTimestamp = String(expiryDate.timeIntervalSince1970)
        save(key: expiryKey, value: expiryTimestamp)
    }

    public func getAccessToken() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return load(key: accessKey)
    }

    public func getRefreshToken() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return load(key: refreshKey)
    }

    public func isTokenExpired() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard let expiryStr = load(key: expiryKey),
              let timestamp = Double(expiryStr) else {
            return true
        }

        // Add 60-second buffer before actual expiry
        return Date().timeIntervalSince1970 >= (timestamp - 60)
    }

    public func clearTokens() {
        lock.lock()
        defer { lock.unlock() }

        delete(key: accessKey)
        delete(key: refreshKey)
        delete(key: expiryKey)
    }

    // MARK: - Private Keychain Helpers

    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Remove existing entry before writing
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

