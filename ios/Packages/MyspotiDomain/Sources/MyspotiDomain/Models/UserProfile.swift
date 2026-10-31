import Foundation

/// Represents the authenticated Spotify user profile.
public struct UserProfile: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let uri: String
    public let displayName: String
    public let email: String?
    public let product: String // "premium", "free", "open"
    public let country: String?
    public let images: [ImageReference]

    public init(
        id: String,
        uri: String,
        displayName: String,
        email: String? = nil,
        product: String = "free",
        country: String? = nil,
        images: [ImageReference] = []
    ) {
        self.id = id
        self.uri = uri
        self.displayName = displayName
        self.email = email
        self.product = product
        self.country = country
        self.images = images
    }

    public var isPremium: Bool {
        product.lowercased() == "premium"
    }

    public var avatarUrl: String? {
        images.first?.url
    }
}

