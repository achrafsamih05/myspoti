import Foundation
import AVFoundation

/// Configures AVAudioSession and handles interruptions and audio route changes.
public final class AudioSessionCoordinator: @unchecked Sendable {
    public var onInterruptionBegan: (() -> Void)?
    public var onInterruptionEnded: ((_ shouldResume: Bool) -> Void)?
    public var onRouteChangedToUnplugged: (() -> Void)?

    private var isConfigured = false

    public init() {
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Activates the audio session with category .playback to enable background audio.
    public func activatePlaybackSession() {
        guard !isConfigured else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            try session.setActive(true)
            isConfigured = true
        } catch {
            print("Failed to activate AVAudioSession: \(error.localizedDescription)")
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            onInterruptionBegan?()
        case .ended:
            let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            let shouldResume = options.contains(.shouldResume)
            onInterruptionEnded?(shouldResume)
        @unknown default:
            break
        }
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        // When headphones / Bluetooth are disconnected, pause audio per Apple HIG
        if reason == .oldDeviceUnavailable {
            onRouteChangedToUnplugged?()
        }
    }
}

