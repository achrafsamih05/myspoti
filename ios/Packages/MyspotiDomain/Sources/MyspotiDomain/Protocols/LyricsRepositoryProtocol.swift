import Foundation

/// Defines lyrics retrieval through the independent LRCLIB service.
public protocol LyricsRepositoryProtocol: Sendable {
    /// Retrieves synchronized or plain lyrics from LRCLIB.
    func getLyrics(
        trackName: String,
        artistName: String,
        albumName: String?,
        durationSeconds: Int?
    ) async throws -> Lyrics?
}

