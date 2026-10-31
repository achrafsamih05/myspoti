import Foundation

/// Represents a Spotify playlist, complying with 2026 Web API structures.
public struct Playlist: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let uri: String
    public let name: String
    public let description: String?
    public let ownerName: String?
    public let images: [ImageReference]
    public let totalItems: Int
    public let isCollaborative: Bool
    public let isPublic: Bool?

    public init(
        id: String,
        uri: String,
        name: String,
        description: String? = nil,
        ownerName: String? = nil,
        images: [ImageReference] = [],
        totalItems: Int = 0,
        isCollaborative: Bool = false,
        isPublic: Bool? = true
    ) {
        self.id = id
        self.uri = uri
        self.name = name
        self.description = description
        self.ownerName = ownerName
        self.images = images
        self.totalItems = totalItems
        self.isCollaborative = isCollaborative
        self.isPublic = isPublic
    }

    public var coverUrl: String? {
        images.first?.url
    }
}

/// Represents an item row within a playlist (migrated from tracks to items in 2026).
public struct PlaylistItem: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let addedAt: String?
    public let track: Track

    public init(id: String, addedAt: String? = nil, track: Track) {
        self.id = id
        self.addedAt = addedAt
        self.track = track
    }
}

