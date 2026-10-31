import Foundation
import MyspotiDomain

/// Mock lyrics repository providing sample synchronized lyric lines for player previews and testing.
public final class MockLyricsRepository: LyricsRepositoryProtocol, Sendable {
    public init() {}

    public func getLyrics(
        trackName: String,
        artistName: String,
        albumName: String? = nil,
        durationSeconds: Int? = nil
    ) async throws -> Lyrics? {
        let sampleLRC = """
        [00:05.00] (Instrumental algorithmic opening - SoundHelix)
        [00:15.00] Gentle ambient synth pads rising in harmony
        [00:25.00] Subtle rhythmic percussion starts to build
        [00:35.00] Smooth melodic piano arpeggio enters the mix
        [00:48.00] Full electronic bassline supporting the melody
        [01:05.00] Dynamic peak of the algorithmic progression
        [01:25.00] Ethereal soundscape fading with gentle reverb
        [01:45.00] Creative Commons licensed audio (CC BY 4.0)
        """

        let lines = LyricsParser.parseLRC(sampleLRC)
        return Lyrics(
            id: 201,
            trackName: trackName,
            artistName: artistName,
            plainLyrics: lines.map(\.content).joined(separator: "\n"),
            lines: lines,
            isSynced: true
        )
    }
}
