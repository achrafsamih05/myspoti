import Foundation

/// Defines library operations conforming to 2026 unified library endpoints.
public protocol LibraryRepositoryProtocol: Sendable {
    /// Fetches saved user tracks.
    func getSavedTracks(limit: Int, offset: Int) async throws -> [Track]

    /// Fetches user's owned and followed playlists.
    func getUserPlaylists(limit: Int, offset: Int) async throws -> [Playlist]

    /// Fetches items from a playlist (migrated to /items in 2026).
    func getPlaylistItems(playlistId: String) async throws -> [PlaylistItem]

    /// Checks whether specific Spotify URIs are saved in the user's library.
    func containsInLibrary(uris: [String]) async throws -> [String: Bool]

    /// Saves content URIs to user's unified library (PUT /v1/me/library).
    func addToLibrary(uris: [String]) async throws

    /// Removes content URIs from user's unified library (DELETE /v1/me/library).
    func removeFromLibrary(uris: [String]) async throws
}

