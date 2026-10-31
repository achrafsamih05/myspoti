import Foundation

/// Synchronized lyrics representation from LRCLIB.
public struct Lyrics: Hashable, Codable, Sendable {
    public let id: Int?
    public let trackName: String
    public let artistName: String
    public let plainLyrics: String?
    public let lines: [LyricsLine]
    public let isSynced: Bool

    public init(
        id: Int? = nil,
        trackName: String,
        artistName: String,
        plainLyrics: String? = nil,
        lines: [LyricsLine] = [],
        isSynced: Bool = false
    ) {
        self.id = id
        self.trackName = trackName
        self.artistName = artistName
        self.plainLyrics = plainLyrics
        self.lines = lines
        self.isSynced = isSynced
    }
}

/// A single timestamped line of synchronized lyrics.
public struct LyricsLine: Identifiable, Hashable, Codable, Sendable {
    public var id: String { "\(startTimeMs)-\(content)" }
    public let startTimeMs: Int
    public let content: String

    public init(startTimeMs: Int, content: String) {
        self.startTimeMs = startTimeMs
        self.content = content
    }

    public var formattedTime: String {
        let totalSeconds = startTimeMs / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

public enum LyricsParser {
    /// Parses LRC formatted text into structured LyricsLine array.
    /// Example: `[01:23.45] Some singing line here`
    public static func parseLRC(_ lrcText: String) -> [LyricsLine] {
        var result: [LyricsLine] = []
        let lines = lrcText.components(separatedBy: .newlines)
        
        let pattern = #"^\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let range = NSRange(location: 0, length: trimmed.utf16.count)
            guard let match = regex.firstMatch(in: trimmed, options: [], range: range) else {
                continue
            }

            guard match.numberOfRanges == 5,
                  let minRange = Range(match.range(at: 1), in: trimmed),
                  let secRange = Range(match.range(at: 2), in: trimmed),
                  let fracRange = Range(match.range(at: 3), in: trimmed),
                  let textRange = Range(match.range(at: 4), in: trimmed) else {
                continue
            }

            let minutes = Int(trimmed[minRange]) ?? 0
            let seconds = Int(trimmed[secRange]) ?? 0
            let fracStr = String(trimmed[fracRange])
            let ms: Int
            if fracStr.count == 2 {
                ms = (Int(fracStr) ?? 0) * 10
            } else {
                ms = Int(fracStr) ?? 0
            }

            let totalMs = (minutes * 60 + seconds) * 1000 + ms
            let text = trimmed[textRange].trimmingCharacters(in: .whitespaces)

            result.append(LyricsLine(startTimeMs: totalMs, content: text))
        }

        return result.sorted { $0.startTimeMs < $1.startTimeMs }
    }
}

