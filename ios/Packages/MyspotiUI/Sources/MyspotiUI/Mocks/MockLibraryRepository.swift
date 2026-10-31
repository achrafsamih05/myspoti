import Foundation
import MyspotiDomain

/// Mock library repository conforming to 2026 unified library contracts.
public final class MockLibraryRepository: LibraryRepositoryProtocol, @unchecked Sendable {
    private var savedUris: Set<String> = ["spotify:track:1", "spotify:track:2"]

    public init() {}

    public func getSavedTracks(limit: Int, offset: Int) async throws -> [Track] {
        MockCatalogRepository.sampleTracks
    }

    public func getUserPlaylists(limit: Int, offset: Int) async throws -> [Playlist] {
        MockCatalogRepository.samplePlaylists
    }

    public func getPlaylistItems(playlistId: String) async throws -> [PlaylistItem] {
        MockCatalogRepository.sampleTracks.enumerated().map { index, track in
            PlaylistItem(id: "item_\(index)", addedAt: "2026-03-01T12:00:00Z", track: track)
        }
    }

    public func containsInLibrary(uris: [String]) async throws -> [String: Bool] {
        Dictionary(uniqueKeysWithValues: uris.map { ($0, savedUris.contains($0)) })
    }

    public func addToLibrary(uris: [String]) async throws {
        for uri in uris { savedUris.insert(uri) }
    }

    public func removeFromLibrary(uris: [String]) async throws {
        for uri in uris { savedUris.remove(uri) }
    }
}

