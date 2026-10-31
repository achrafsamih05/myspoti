import XCTest
import MyspotiDomain
import MyspotiNetwork

final class MyspotiTests: XCTestCase {

    // MARK: - PKCE Cryptography & RFC 7636 Verification

    func testPKCECodeVerifierGeneration() {
        let coordinator = PKCECoordinator(clientId: "test_client_id")
        let verifier = coordinator.generateCodeVerifier()

        XCTAssertFalse(verifier.isEmpty)
        // RFC 7636 specifies code_verifier length between 43 and 128 characters
        XCTAssertGreaterThanOrEqual(verifier.count, 43)
        XCTAssertLessThanOrEqual(verifier.count, 128)

        // Verifier must not contain standard Base64 padding (=) or non-URL-safe characters (+, /)
        XCTAssertFalse(verifier.contains("="))
        XCTAssertFalse(verifier.contains("+"))
        XCTAssertFalse(verifier.contains("/"))
    }

    func testPKCECodeChallengeDerivation() {
        let coordinator = PKCECoordinator(clientId: "test_client_id")
        let verifier = coordinator.generateCodeVerifier()
        let challenge = coordinator.generateCodeChallenge(from: verifier)

        XCTAssertFalse(challenge.isEmpty)
        XCTAssertFalse(challenge.contains("="))
        XCTAssertFalse(challenge.contains("+"))
        XCTAssertFalse(challenge.contains("/"))
    }

    func testAuthorizeURLConstruction() {
        let coordinator = PKCECoordinator(clientId: "mock_client_123", redirectURI: "myspoti://callback")
        let verifier = coordinator.generateCodeVerifier()
        let challenge = coordinator.generateCodeChallenge(from: verifier)
        let state = "test_state_abc"

        guard let url = coordinator.buildAuthorizeURL(codeChallenge: challenge, state: state) else {
            XCTFail("Failed to build authorize URL")
            return
        }

        let urlString = url.absoluteString
        XCTAssertTrue(urlString.contains("https://accounts.spotify.com/authorize"))
        XCTAssertTrue(urlString.contains("client_id=mock_client_123"))
        XCTAssertTrue(urlString.contains("response_type=code"))
        XCTAssertTrue(urlString.contains("code_challenge_method=S256"))
        XCTAssertTrue(urlString.contains("code_challenge=\(challenge)"))
        XCTAssertTrue(urlString.contains("state=test_state_abc"))
        XCTAssertTrue(urlString.contains("redirect_uri=myspoti%3A%2F%2Fcallback"))
    }

    // MARK: - February 2026 API Migrations & Constraints

    func test2026SearchEndpointCapsLimitAt10() {
        let endpoint = SpotifyEndpoint.search(query: "Daft Punk")
        guard let url = endpoint.url else {
            XCTFail("Invalid search URL")
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let limitItem = components?.queryItems?.first(where: { $0.name == "limit" })
        XCTAssertEqual(limitItem?.value, "10", "Spotify February 2026 guidelines strictly cap search at 10 items")
    }

    func test2026PlaylistItemEndpointMigration() {
        let endpoint = SpotifyEndpoint.playlistItems(playlistId: "playlist_abc", limit: 20, offset: 0)
        XCTAssertEqual(endpoint.path, "/playlists/playlist_abc/items", "2026 migration mandates /items instead of /tracks")
        XCTAssertEqual(endpoint.method, "GET")
    }

    func test2026UnifiedLibraryEndpoint() {
        let containsEndpoint = SpotifyEndpoint.libraryContains(uris: ["spotify:track:1", "spotify:track:2"])
        XCTAssertEqual(containsEndpoint.path, "/me/library/contains")

        let addEndpoint = SpotifyEndpoint.libraryAdd
        XCTAssertEqual(addEndpoint.path, "/me/library")
        XCTAssertEqual(addEndpoint.method, "PUT")

        let removeEndpoint = SpotifyEndpoint.libraryRemove
        XCTAssertEqual(removeEndpoint.path, "/me/library")
        XCTAssertEqual(removeEndpoint.method, "DELETE")
    }

    // MARK: - LRCLIB Synchronized Lyrics Parser

    func testLRCLyricsParserAccuracy() {
        let sampleLRC = """
        [00:12.34] First lyric line
        [01:05.67] Second lyric line after a minute
        [02:30.890] Third lyric line with 3 digit milliseconds
        """

        let parsedLines = LyricsParser.parseLRC(sampleLRC)
        XCTAssertEqual(parsedLines.count, 3)

        // Line 1: 00:12.34 -> 12 * 1000 + 340 = 12340 ms
        XCTAssertEqual(parsedLines[0].startTimeMs, 12340)
        XCTAssertEqual(parsedLines[0].content, "First lyric line")

        // Line 2: 01:05.67 -> (60 + 5) * 1000 + 670 = 65670 ms
        XCTAssertEqual(parsedLines[1].startTimeMs, 65670)
        XCTAssertEqual(parsedLines[1].content, "Second lyric line after a minute")

        // Line 3: 02:30.890 -> (120 + 30) * 1000 + 890 = 150890 ms
        XCTAssertEqual(parsedLines[2].startTimeMs, 150890)
        XCTAssertEqual(parsedLines[2].content, "Third lyric line with 3 digit milliseconds")
    }

    // MARK: - Domain Models & Duration Formatting

    func testTrackDurationFormatting() {
        let track = Track(
            id: "t1",
            uri: "spotify:track:1",
            name: "Test Song",
            durationMs: 215000, // 3 minutes 35 seconds
            artists: [ArtistReference(id: "a1", uri: "spotify:artist:1", name: "Artist A")]
        )

        XCTAssertEqual(track.formattedDuration, "3:35")
        XCTAssertEqual(track.artistNamesSummary, "Artist A")
    }
}

