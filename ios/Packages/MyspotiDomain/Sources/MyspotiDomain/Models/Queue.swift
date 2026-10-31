import Foundation

/// Represents the active playback queue.
public struct PlaybackQueue: Hashable, Codable, Sendable {
    public let currentTrack: Track?
    public let upcomingTracks: [Track]

    public init(currentTrack: Track? = nil, upcomingTracks: [Track] = []) {
        self.currentTrack = currentTrack
        self.upcomingTracks = upcomingTracks
    }
}

