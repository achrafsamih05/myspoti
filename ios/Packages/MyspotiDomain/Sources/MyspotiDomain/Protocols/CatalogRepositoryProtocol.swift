import Foundation

/// Defines catalog search and lookup operations complying with February 2026 Web API.
public protocol CatalogRepositoryProtocol: Sendable {
    /// Searches Spotify catalog across tracks, albums, artists, and playlists.
    /// Notice: Spotify 2026 strictly caps search results at a maximum of 10 items.
    func search(query: String, limit: Int) async throws -> SearchResults

    /// Fetches detailed metadata for a specific album.
    func getAlbum(id: String) async throws -> Album

    /// Fetches track items for a specific album.
    func getAlbumTracks(albumId: String) async throws -> [Track]

    /// Fetches artist profile and discography overview.
    func getArtist(id: String) async throws -> Artist
}

/// Unified search container capped at 10 results per entity type.
public struct SearchResults: Hashable, Codable, Sendable {
    public let tracks: [Track]
    public let albums: [Album]
    public let artists: [Artist]
    public let playlists: [Playlist]

    public init(
        tracks: [Track] = [],
        albums: [Album] = [],
        artists: [Artist] = [],
        playlists: [Playlist] = []
    ) {
        // Enforce 2026 limit of 10 items per collection
        self.tracks = Array(tracks.prefix(10))
        self.albums = Array(albums.prefix(10))
        self.artists = Array(artists.prefix(10))
        self.playlists = Array(playlists.prefix(10))
    }
}

