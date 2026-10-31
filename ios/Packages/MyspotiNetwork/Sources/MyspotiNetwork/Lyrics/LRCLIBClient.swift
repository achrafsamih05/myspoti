import Foundation
import MyspotiDomain

/// Public API client for the independent LRCLIB lyrics service.
public final class LRCLIBClient: LyricsRepositoryProtocol, Sendable {
    private let httpClient: HTTPClient
    private static let userAgent = "Myspoti-iOS/1.0 (https://github.com/kota-zo/myspoti)"

    public init(httpClient: HTTPClient = HTTPClient()) {
        self.httpClient = httpClient
    }

    public func getLyrics(
        trackName: String,
        artistName: String,
        albumName: String? = nil,
        durationSeconds: Int? = nil
    ) async throws -> Lyrics? {
        let endpoint = LRCLIBEndpoint.get(
            trackName: trackName,
            artistName: artistName,
            albumName: albumName,
            durationSeconds: durationSeconds
        )

        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let response: LRCLIBResponse = try await httpClient.execute(request: request)
            let lines: [LyricsLine]
            if let synced = response.syncedLyrics, !synced.isEmpty {
                lines = LyricsParser.parseLRC(synced)
            } else {
                lines = []
            }

            return Lyrics(
                id: response.id,
                trackName: response.trackName,
                artistName: response.artistName,
                plainLyrics: response.plainLyrics,
                lines: lines,
                isSynced: !lines.isEmpty
            )
        } catch NetworkError.notFound {
            return nil
        } catch {
            return nil // Graceful fallback when lyrics unavailable
        }
    }
}

private struct LRCLIBResponse: Decodable {
    let id: Int?
    let trackName: String
    let artistName: String
    let albumName: String?
    let duration: Double?
    let plainLyrics: String?
    let syncedLyrics: String?
}

