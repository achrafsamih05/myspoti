import Foundation
import MyspotiDomain

/// Concrete implementation of PlaybackRepositoryProtocol backed by NativeAudioEngine.
public final class NativePlaybackRepository: PlaybackRepositoryProtocol, @unchecked Sendable {
    private let engine: NativeAudioEngine
    private let sessionCoordinator: AudioSessionCoordinator
    private let nowPlayingCoordinator: NowPlayingCoordinator
    private var streamContinuation: AsyncStream<PlaybackState>.Continuation?

    public init(
        engine: NativeAudioEngine = NativeAudioEngine(),
        sessionCoordinator: AudioSessionCoordinator = AudioSessionCoordinator(),
        nowPlayingCoordinator: NowPlayingCoordinator = NowPlayingCoordinator()
    ) {
        self.engine = engine
        self.sessionCoordinator = sessionCoordinator
        self.nowPlayingCoordinator = nowPlayingCoordinator

        setupIntegration()
    }

    private func setupIntegration() {
        // Activate audio session
        sessionCoordinator.activatePlaybackSession()

        // Sync engine state to UI stream and Lock Screen
        engine.onStateChanged = { [weak self] state in
            self?.streamContinuation?.yield(state)
            self?.nowPlayingCoordinator.updateNowPlaying(
                track: state.currentTrack,
                progressMs: state.progressMs,
                isPlaying: state.isPlaying
            )
        }

        // Handle Audio Session interruptions
        sessionCoordinator.onInterruptionBegan = { [weak self] in
            self?.engine.pause()
        }
        sessionCoordinator.onInterruptionEnded = { [weak self] shouldResume in
            if shouldResume { self?.engine.resume() }
        }
        sessionCoordinator.onRouteChangedToUnplugged = { [weak self] in
            self?.engine.pause()
        }

        // Handle Remote Lock Screen Commands
        nowPlayingCoordinator.onPlayCommand = { [weak self] in
            self?.engine.resume()
        }
        nowPlayingCoordinator.onPauseCommand = { [weak self] in
            self?.engine.pause()
        }
        nowPlayingCoordinator.onNextCommand = { [weak self] in
            self?.engine.skipNext()
        }
        nowPlayingCoordinator.onPreviousCommand = { [weak self] in
            self?.engine.skipPrevious()
        }
        nowPlayingCoordinator.onSeekCommand = { [weak self] positionMs in
            self?.engine.seek(toPositionMs: positionMs)
        }
    }

    // MARK: - PlaybackRepositoryProtocol

    public func observePlaybackState() -> AsyncStream<PlaybackState> {
        AsyncStream { continuation in
            self.streamContinuation = continuation
            let initialState = PlaybackState(
                isPlaying: self.engine.isPlaying,
                progressMs: self.engine.progressMs,
                currentTrack: self.engine.currentTrack,
                device: Device(id: "iphone_local", name: "iPhone (Native Audio)", type: "Smartphone", isActive: true),
                shuffleState: self.engine.shuffleEnabled,
                repeatState: self.engine.repeatMode
            )
            continuation.yield(initialState)
        }
    }

    public func play(uri: String?, contextUri: String?) async throws {
        // Look up track or resume
        engine.resume()
    }

    public func playTrack(_ track: Track) async throws {
        engine.loadAndPlay(track: track)
    }

    public func pause() async throws {
        engine.pause()
    }

    public func resume() async throws {
        engine.resume()
    }

    public func next() async throws {
        engine.skipNext()
    }

    public func previous() async throws {
        engine.skipPrevious()
    }

    public func seek(positionMs: Int) async throws {
        engine.seek(toPositionMs: positionMs)
    }

    public func toggleShuffle() async throws {
        engine.toggleShuffle()
    }

    public func toggleRepeat() async throws {
        engine.toggleRepeat()
    }

    public func getQueue() async -> PlaybackQueue {
        engine.getQueue()
    }

    public func addToQueue(_ track: Track) async {
        engine.enqueue(track: track)
    }

    public func removeFromQueue(trackId: String) async {
        engine.remove(trackId: trackId)
    }

    public func getAvailableDevices() async throws -> [Device] {
        [Device(id: "iphone_local", name: "iPhone (Native Audio)", type: "Smartphone", isActive: true)]
    }

    public func transferPlayback(toDeviceId deviceId: String) async throws {
        // Native audio stays on iPhone
    }
}

