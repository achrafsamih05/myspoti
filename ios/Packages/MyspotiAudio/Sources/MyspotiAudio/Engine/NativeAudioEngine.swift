import Foundation
import AVFoundation
import MyspotiDomain

/// Native audio engine utilizing AVPlayer for authorized and legal audio streams.
public final class NativeAudioEngine: NSObject, @unchecked Sendable {
    private var player: AVPlayer
    private var timeObserver: Any?
    private var endObserverToken: NSObjectProtocol?
    private let lock = NSLock()

    private(set) public var currentTrack: Track?
    private(set) public var upcomingQueue: [Track] = []
    private(set) public var history: [Track] = []
    private(set) public var isPlaying: Bool = false
    private(set) public var progressMs: Int = 0
    private(set) public var shuffleEnabled: Bool = false
    private(set) public var repeatMode: RepeatMode = .off

    public var onStateChanged: ((_ state: PlaybackState) -> Void)?

    public override init() {
        self.player = AVPlayer()
        super.init()
        self.player.automaticallyWaitsToMinimizeStalling = true
        setupTimeObserver()
        setupEndObserver()
    }

    deinit {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
        if let token = endObserverToken {
            NotificationCenter.default.removeObserver(token)
            endObserverToken = nil
        }
        stopSimulatedClock()
    }

    // MARK: - Playback Operations

    public func loadAndPlay(track: Track) {
        lock.lock()
        currentTrack = track
        progressMs = 0
        isPlaying = true
        lock.unlock()

        broadcastState()

        guard let urlStr = track.audioStreamUrl, let url = URL(string: urlStr) else {
            // Simulated playback progress for preview/mock tracks with no remote URL
            player.pause()
            startSimulatedClock()
            return
        }

        stopSimulatedClock()
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }

    public func pause() {
        lock.lock()
        isPlaying = false
        lock.unlock()

        player.pause()
        stopSimulatedClock()
        broadcastState()
    }

    public func resume() {
        lock.lock()
        isPlaying = true
        lock.unlock()

        if player.currentItem != nil {
            player.play()
        } else {
            startSimulatedClock()
        }
        broadcastState()
    }

    public func seek(toPositionMs: Int) {
        lock.lock()
        progressMs = toPositionMs
        lock.unlock()

        if player.currentItem != nil {
            let time = CMTime(value: CMTimeValue(toPositionMs), timescale: 1000)
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        broadcastState()
    }

    public func skipNext() {
        lock.lock()
        if let current = currentTrack {
            history.append(current)
        }

        guard !upcomingQueue.isEmpty else {
            if repeatMode == .context, let first = history.first {
                lock.unlock()
                loadAndPlay(track: first)
                return
            }
            lock.unlock()
            pause()
            return
        }

        let nextTrack = upcomingQueue.removeFirst()
        lock.unlock()

        loadAndPlay(track: nextTrack)
    }

    public func skipPrevious() {
        lock.lock()
        // If track has been playing for > 3 seconds, restart it
        if progressMs > 3000 {
            lock.unlock()
            seek(toPositionMs: 0)
            return
        }

        guard let lastPlayed = history.popLast() else {
            lock.unlock()
            seek(toPositionMs: 0)
            return
        }
        lock.unlock()

        loadAndPlay(track: lastPlayed)
    }

    public func toggleShuffle() {
        lock.lock()
        shuffleEnabled.toggle()
        if shuffleEnabled {
            upcomingQueue.shuffle()
        }
        lock.unlock()
        broadcastState()
    }

    public func toggleRepeat() {
        lock.lock()
        switch repeatMode {
        case .off: repeatMode = .context
        case .context: repeatMode = .track
        case .track: repeatMode = .off
        }
        lock.unlock()
        broadcastState()
    }

    // MARK: - Queue Operations

    public func enqueue(track: Track) {
        lock.lock()
        upcomingQueue.append(track)
        lock.unlock()
        broadcastState()
    }

    public func remove(trackId: String) {
        lock.lock()
        upcomingQueue.removeAll { $0.id == trackId }
        lock.unlock()
        broadcastState()
    }

    public func getQueue() -> PlaybackQueue {
        lock.lock()
        defer { lock.unlock() }
        return PlaybackQueue(currentTrack: currentTrack, upcomingTracks: upcomingQueue)
    }

    // MARK: - Internal Observers

    private func setupTimeObserver() {
        let interval = CMTime(value: 250, timescale: 1000) // 250ms periodic updates
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, self.isPlaying else { return }
            let ms = Int(CMTimeGetSeconds(time) * 1000)
            self.lock.lock()
            self.progressMs = ms
            self.lock.unlock()
            self.broadcastState()
        }
    }

    private func setupEndObserver() {
        endObserverToken = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            // Verify notification belongs to the active player's item
            if let finishedItem = notification.object as? AVPlayerItem,
               finishedItem == self.player.currentItem {
                if self.repeatMode == .track, let current = self.currentTrack {
                    self.seek(toPositionMs: 0)
                    self.resume()
                } else {
                    self.skipNext()
                }
            }
        }
    }

    private var simulatedTimer: Timer?

    private func startSimulatedClock() {
        stopSimulatedClock()
        simulatedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            self.lock.lock()
            let newProgress = self.progressMs + 1000
            let duration = self.currentTrack?.durationMs ?? 180000
            if newProgress >= duration {
                self.progressMs = 0
                self.lock.unlock()
                self.skipNext()
            } else {
                self.progressMs = newProgress
                self.lock.unlock()
                self.broadcastState()
            }
        }
    }

    private func stopSimulatedClock() {
        simulatedTimer?.invalidate()
        simulatedTimer = nil
    }

    private func broadcastState() {
        let state = PlaybackState(
            isPlaying: isPlaying,
            progressMs: progressMs,
            currentTrack: currentTrack,
            device: Device(id: "iphone_local", name: "iPhone (Native Audio)", type: "Smartphone", isActive: true),
            shuffleState: shuffleEnabled,
            repeatState: repeatMode
        )
        DispatchQueue.main.async { [weak self] in
            self?.onStateChanged?(state)
        }
    }
}
