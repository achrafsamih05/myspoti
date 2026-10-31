import Foundation

/// Represents a musical track or recording.
public struct Track: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let uri: String
    public let name: String
    public let durationMs: Int
    public let artists: [ArtistReference]
    public let album: AlbumReference?
    public let explicit: Bool
    public let isPlayable: Bool
    public let previewUrl: String?
    /// Direct streamable audio URL for native AVPlayer playback (authorized podcast, local file, or legal sample)
    public let audioStreamUrl: String?

    public init(
        id: String,
        uri: String,
        name: String,
        durationMs: Int,
        artists: [ArtistReference],
        album: AlbumReference? = nil,
        explicit: Bool = false,
        isPlayable: Bool = true,
        previewUrl: String? = nil,
        audioStreamUrl: String? = nil
    ) {
        self.id = id
        self.uri = uri
        self.name = name
        self.durationMs = durationMs
        self.artists = artists
        self.album = album
        self.explicit = explicit
        self.isPlayable = isPlayable
        self.previewUrl = previewUrl
        self.audioStreamUrl = audioStreamUrl ?? previewUrl
    }

    public var formattedDuration: String {
        let totalSeconds = durationMs / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    public var artistNamesSummary: String {
        artists.map(\.name).joined(separator: ", ")
    }
}

public struct ArtistReference: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let uri: String
    public let name: String

    public init(id: String, uri: String, name: String) {
        self.id = id
        self.uri = uri
        self.name = name
    }
}

public struct AlbumReference: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let uri: String
    public let name: String
    public let images: [ImageReference]

    public init(id: String, uri: String, name: String, images: [ImageReference] = []) {
        self.id = id
        self.uri = uri
        self.name = name
        self.images = images
    }

    public var coverUrl: String? {
        images.first?.url
    }
}

public struct ImageReference: Hashable, Codable, Sendable {
    public let url: String
    public let width: Int?
    public let height: Int?

    public init(url: String, width: Int? = nil, height: Int? = nil) {
        self.url = url
        self.width = width
        self.height = height
    }
}
