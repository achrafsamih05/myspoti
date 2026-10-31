import Foundation

/// Represents a musical artist or creator.
public struct Artist: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let uri: String
    public let name: String
    public let images: [ImageReference]
    public let genres: [String]
    public let followersCount: Int?

    public init(
        id: String,
        uri: String,
        name: String,
        images: [ImageReference] = [],
        genres: [String] = [],
        followersCount: Int? = nil
    ) {
        self.id = id
        self.uri = uri
        self.name = name
        self.images = images
        self.genres = genres
        self.followersCount = followersCount
    }

    public var avatarUrl: String? {
        images.first?.url
    }
}

