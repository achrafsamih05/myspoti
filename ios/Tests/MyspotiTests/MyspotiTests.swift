import XCTest
import MyspotiDomain
import MyspotiNetwork

final class MyspotiTests: XCTestCase {

    // MARK: - PKCE Cryptography & RFC 7636 Verification

    func testPKCECodeVerifierGeneration() throws {
        let coordinator = PKCECoordinator(clientId: "test_client_id")
        let verifier = try coordinator.generateCodeVerifier()

        XCTAssertFalse(verifier.isEmpty)
        // RFC 7636 specifies code_verifier length between 43 and 128 characters (32 bytes = 43 chars base64url)
        XCTAssertGreaterThanOrEqual(verifier.count, 43)
        XCTAssertLessThanOrEqual(verifier.count, 128)

        // Verifier must not contain standard Base64 padding (=) or non-URL-safe characters (+, /)
        XCTAssertFalse(verifier.contains("="))
        XCTAssertFalse(verifier.contains("+"))
        XCTAssertFalse(verifier.contains("/"))
    }

    func testPKCECodeChallengeDerivation() throws {
        let coordinator = PKCECoordinator(clientId: "test_client_id")
        let verifier = try coordinator.generateCodeVerifier()
        let challenge = coordinator.generateCodeChallenge(from: verifier)

        XCTAssertFalse(challenge.isEmpty)
        XCTAssertFalse(challenge.contains("="))
        XCTAssertFalse(challenge.contains("+"))
        XCTAssertFalse(challenge.contains("/"))
    }

    func testPKCECodeChallengeKnownTestVector() {
        let coordinator = PKCECoordinator(clientId: "test_client_id")
        // RFC 7636 Appendix B test vector
        let verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
        let expectedChallenge = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"

        let actualChallenge = coordinator.generateCodeChallenge(from: verifier)
        XCTAssertEqual(actualChallenge, expectedChallenge, "RFC 7636 test vector challenge derivation mismatch")
    }

    func testPKCESecureRandomGenerationFailureHandling() {
        let coordinator = PKCECoordinator(clientId: "test_client_id")
        let simulatedFailureStatus: OSStatus = -1

        XCTAssertThrowsError(
            try coordinator.generateCodeVerifier(randomBytesGenerator: { _ in
                throw PKCEError.randomGenerationFailed(simulatedFailureStatus)
            }),
            "Should throw PKCEError when random generation fails"
        ) { error in
            guard let pkceError = error as? PKCEError else {
                XCTFail("Expected PKCEError but received \(error)")
                return
            }
            XCTAssertEqual(pkceError, PKCEError.randomGenerationFailed(simulatedFailureStatus))
        }
    }

    func testPKCECodeVerifierInvalidByteCountHandling() {
        let coordinator = PKCECoordinator(clientId: "test_client_id")

        XCTAssertThrowsError(
            try coordinator.generateCodeVerifier(randomBytesGenerator: { _ in
                [UInt8](repeating: 1, count: 16)
            }),
            "Should throw PKCEError.invalidByteCount when byte count is insufficient"
        ) { error in
            XCTAssertEqual(error as? PKCEError, PKCEError.invalidByteCount(expected: 32, actual: 16))
        }
    }

    func testPKCECodeVerifierDeterministicCustomBytes() throws {
        let coordinator = PKCECoordinator(clientId: "test_client_id")
        let fixedBytes = [UInt8](repeating: 0x41, count: 32)
        let verifier = try coordinator.generateCodeVerifier(randomBytesGenerator: { _ in fixedBytes })
        XCTAssertEqual(verifier, "QUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUE")
    }

    // MARK: - OAuth Authorization URL Construction & Validation

    func testAuthorizeURLConstruction() throws {
        let clientId = "mock_client_123"
        let redirectURI = "myspoti://callback"
        let coordinator = PKCECoordinator(clientId: clientId, redirectURI: redirectURI)
        let verifier = try coordinator.generateCodeVerifier()
        let challenge = coordinator.generateCodeChallenge(from: verifier)
        let state = "test_state_abc"

        guard let url = coordinator.buildAuthorizeURL(codeChallenge: challenge, state: state) else {
            XCTFail("Failed to build authorize URL")
            return
        }

        // Validate structure via URLComponents
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            XCTFail("Failed to parse authorize URL with URLComponents")
            return
        }

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "accounts.spotify.com")
        XCTAssertEqual(components.path, "/authorize")

        // Validate decoded query items dictionary
        let queryItems = components.queryItems ?? []
        let queryMap = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
            item.value.map { (item.name, $0) }
        })

        XCTAssertEqual(queryMap["client_id"], clientId)
        XCTAssertEqual(queryMap["response_type"], "code")
        XCTAssertEqual(queryMap["redirect_uri"], redirectURI, "Decoded redirect_uri parameter must match expected URI")
        XCTAssertEqual(queryMap["code_challenge_method"], "S256")
        XCTAssertEqual(queryMap["code_challenge"], challenge)
        XCTAssertEqual(queryMap["state"], state)

        guard let scope = queryMap["scope"] else {
            XCTFail("Scope query item is missing")
            return
        }
        XCTAssertTrue(scope.contains("user-read-playback-state"))
        XCTAssertTrue(scope.contains("user-modify-playback-state"))
        XCTAssertTrue(scope.contains("user-library-read"))
    }

    // MARK: - Form URL Encoding (RFC 1866 / WHATWG)

    func testFormURLEncodingReservedCharactersAndSpaces() {
        // Individual field encoding
        XCTAssertEqual(PKCECoordinator.encodeFormField("hello world"), "hello+world", "Spaces must be encoded as +")
        XCTAssertEqual(PKCECoordinator.encodeFormField("myspoti://callback"), "myspoti%3A%2F%2Fcallback", "Colons and slashes must be percent-encoded")
        XCTAssertEqual(PKCECoordinator.encodeFormField("test+plus"), "test%2Bplus", "Literal + must be percent-encoded to %2B to avoid confusion with spaces")
        XCTAssertEqual(PKCECoordinator.encodeFormField("key=value&foo=bar"), "key%3Dvalue%26foo%3Dbar", "= and & must be percent-encoded")
        XCTAssertEqual(PKCECoordinator.encodeFormField("safe-name_1.0~"), "safe-name_1.0~", "RFC 3986 unreserved characters must remain unencoded")

        // Full parameter dictionary encoding
        let params = [
            "client_id": "test client",
            "grant_type": "authorization_code",
            "redirect_uri": "myspoti://callback"
        ]

        guard let bodyData = PKCECoordinator.formURLEncode(params),
              let bodyString = String(data: bodyData, encoding: .utf8) else {
            XCTFail("Failed to encode form-urlencoded body")
            return
        }

        // Keys must be sorted deterministically
        let expected = "client_id=test+client&grant_type=authorization_code&redirect_uri=myspoti%3A%2F%2Fcallback"
        XCTAssertEqual(bodyString, expected)
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
