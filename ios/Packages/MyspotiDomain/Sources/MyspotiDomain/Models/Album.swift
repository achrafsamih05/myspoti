import Foundation

/// Represents an album or release.
public struct Album: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let uri: String
    public let name: String
    public let artists: [ArtistReference]
    public let images: [ImageReference]
    public let releaseDate: String?
    public let totalTracks: Int
    public let albumType: String?

    public init(
        id: String,
        uri: String,
        name: String,
        artists: [ArtistReference],
        images: [ImageReference],
        releaseDate: String? = nil,
        totalTracks: Int = 0,
        albumType: String? = "album"
    ) {
        self.id = id
        self.uri = uri
        self.name = name
        self.artists = artists
        self.images = images
        self.releaseDate = releaseDate
        self.totalTracks = totalTracks
        self.albumType = albumType
    }

    public var coverUrl: String? {
        images.first?.url
    }

    public var primaryArtistName: String {
        artists.first?.name ?? "Unknown Artist"
    }
}

