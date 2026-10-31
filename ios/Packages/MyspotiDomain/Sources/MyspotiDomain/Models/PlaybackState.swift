import Foundation

/// Active repeat mode on Spotify Connect endpoints.
public enum RepeatMode: String, Codable, Sendable {
    case off
    case context
    case track
}

/// Active playback status received from Spotify Connect or internal player.
public struct PlaybackState: Hashable, Codable, Sendable {
    public let isPlaying: Bool
    public let progressMs: Int
    public let currentTrack: Track?
    public let device: Device?
    public let shuffleState: Bool
    public let repeatState: RepeatMode

    public init(
        isPlaying: Bool = false,
        progressMs: Int = 0,
        currentTrack: Track? = nil,
        device: Device? = nil,
        shuffleState: Bool = false,
        repeatState: RepeatMode = .off
    ) {
        self.isPlaying = isPlaying
        self.progressMs = progressMs
        self.currentTrack = currentTrack
        self.device = device
        self.shuffleState = shuffleState
        self.repeatState = repeatState
    }

    public var progressFraction: Double {
        guard let duration = currentTrack?.durationMs, duration > 0 else { return 0 }
        return min(max(Double(progressMs) / Double(duration), 0), 1)
    }

    public var formattedProgress: String {
        let totalSeconds = progressMs / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

