import Foundation
import MyspotiDomain

/// Mock playback repository with live state stream simulation.
public final class MockPlaybackRepository: PlaybackRepositoryProtocol, @unchecked Sendable {
    private var currentState: PlaybackState
    private var streamContinuation: AsyncStream<PlaybackState>.Continuation?
    private var queue: [Track] = []

    public init(
        initialTrack: Track? = MockCatalogRepository.sampleTracks.first
    ) {
        self.currentState = PlaybackState(
            isPlaying: true,
            progressMs: 45000,
            currentTrack: initialTrack,
            device: Device(id: "mock_iphone", name: "iPhone (Mock Standalone)", type: "Smartphone", isActive: true),
            shuffleState: false,
            repeatState: .off
        )
        self.queue = Array(MockCatalogRepository.sampleTracks.dropFirst())
    }

    public func observePlaybackState() -> AsyncStream<PlaybackState> {
        AsyncStream { continuation in
            self.streamContinuation = continuation
            continuation.yield(self.currentState)
        }
    }

    public func play(uri: String?, contextUri: String?) async throws {
        let track = MockCatalogRepository.sampleTracks.first { $0.uri == uri } ?? currentState.currentTrack
        currentState = PlaybackState(
            isPlaying: true,
            progressMs: currentState.progressMs,
            currentTrack: track,
            device: currentState.device,
            shuffleState: currentState.shuffleState,
            repeatState: currentState.repeatState
        )
        streamContinuation?.yield(currentState)
    }

    public func playTrack(_ track: Track) async throws {
        currentState = PlaybackState(
            isPlaying: true,
            progressMs: 0,
            currentTrack: track,
            device: currentState.device,
            shuffleState: currentState.shuffleState,
            repeatState: currentState.repeatState
        )
        streamContinuation?.yield(currentState)
    }

    public func pause() async throws {
        currentState = PlaybackState(
            isPlaying: false,
            progressMs: currentState.progressMs,
            currentTrack: currentState.currentTrack,
            device: currentState.device,
            shuffleState: currentState.shuffleState,
            repeatState: currentState.repeatState
        )
        streamContinuation?.yield(currentState)
    }

    public func resume() async throws {
        currentState = PlaybackState(
            isPlaying: true,
            progressMs: currentState.progressMs,
            currentTrack: currentState.currentTrack,
            device: currentState.device,
            shuffleState: currentState.shuffleState,
            repeatState: currentState.repeatState
        )
        streamContinuation?.yield(currentState)
    }

    public func next() async throws {
        let all = MockCatalogRepository.sampleTracks
        let currentIndex = all.firstIndex { $0.id == currentState.currentTrack?.id } ?? 0
        let nextIndex = (currentIndex + 1) % all.count
        try await play(uri: all[nextIndex].uri, contextUri: nil)
    }

    public func previous() async throws {
        let all = MockCatalogRepository.sampleTracks
        let currentIndex = all.firstIndex { $0.id == currentState.currentTrack?.id } ?? 0
        let prevIndex = (currentIndex - 1 + all.count) % all.count
        try await play(uri: all[prevIndex].uri, contextUri: nil)
    }

    public func seek(positionMs: Int) async throws {
        currentState = PlaybackState(
            isPlaying: currentState.isPlaying,
            progressMs: positionMs,
            currentTrack: currentState.currentTrack,
            device: currentState.device,
            shuffleState: currentState.shuffleState,
            repeatState: currentState.repeatState
        )
        streamContinuation?.yield(currentState)
    }

    public func toggleShuffle() async throws {
        currentState = PlaybackState(
            isPlaying: currentState.isPlaying,
            progressMs: currentState.progressMs,
            currentTrack: currentState.currentTrack,
            device: currentState.device,
            shuffleState: !currentState.shuffleState,
            repeatState: currentState.repeatState
        )
        streamContinuation?.yield(currentState)
    }

    public func toggleRepeat() async throws {
        let nextRepeat: RepeatMode
        switch currentState.repeatState {
        case .off: nextRepeat = .context
        case .context: nextRepeat = .track
        case .track: nextRepeat = .off
        }
        currentState = PlaybackState(
            isPlaying: currentState.isPlaying,
            progressMs: currentState.progressMs,
            currentTrack: currentState.currentTrack,
            device: currentState.device,
            shuffleState: currentState.shuffleState,
            repeatState: nextRepeat
        )
        streamContinuation?.yield(currentState)
    }

    public func getQueue() async -> PlaybackQueue {
        PlaybackQueue(currentTrack: currentState.currentTrack, upcomingTracks: queue)
    }

    public func addToQueue(_ track: Track) async {
        queue.append(track)
    }

    public func removeFromQueue(trackId: String) async {
        queue.removeAll { $0.id == trackId }
    }

    public func getAvailableDevices() async throws -> [Device] {
        [
            Device(id: "mock_iphone", name: "iPhone (Native Audio)", type: "Smartphone", isActive: true)
        ]
    }

    public func transferPlayback(toDeviceId deviceId: String) async throws {}
}
