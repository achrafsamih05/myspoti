import Foundation

/// Defines playback control and monitoring contracts.
public protocol PlaybackRepositoryProtocol: Sendable {
    /// Observes real-time playback state updates.
    func observePlaybackState() -> AsyncStream<PlaybackState>

    /// Plays a specific track with optional context.
    func play(uri: String?, contextUri: String?) async throws

    /// Directly loads and plays a specific Track object (for native AVPlayer playback).
    func playTrack(_ track: Track) async throws

    /// Pauses current playback.
    func pause() async throws

    /// Resumes current playback.
    func resume() async throws

    /// Skips to the next track.
    func next() async throws

    /// Skips to the previous track.
    func previous() async throws

    /// Seeks to a specific millisecond position in the current track.
    func seek(positionMs: Int) async throws

    /// Toggles shuffle state.
    func toggleShuffle() async throws

    /// Advances repeat mode (off -> context -> track -> off).
    func toggleRepeat() async throws

    /// Gets the current playback queue.
    func getQueue() async -> PlaybackQueue

    /// Appends a track to the playback queue.
    func addToQueue(_ track: Track) async

    /// Removes a track from the upcoming queue.
    func removeFromQueue(trackId: String) async

    /// Fetches currently available playback devices.
    func getAvailableDevices() async throws -> [Device]

    /// Transfers playback to a target device.
    func transferPlayback(toDeviceId deviceId: String) async throws
}
