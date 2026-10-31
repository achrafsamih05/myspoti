import Foundation
import MediaPlayer
import MyspotiDomain

/// Manages system Lock Screen and Control Center media integration via MediaPlayer framework.
public final class NowPlayingCoordinator: @unchecked Sendable {
    public var onPlayCommand: (() -> Void)?
    public var onPauseCommand: (() -> Void)?
    public var onNextCommand: (() -> Void)?
    public var onPreviousCommand: (() -> Void)?
    public var onSeekCommand: ((Int) -> Void)?

    private var commandTargets: [Any] = []

    public init() {
        configureRemoteCommands()
    }

    deinit {
        let commandCenter = MPRemoteCommandCenter.shared()
        for target in commandTargets {
            commandCenter.playCommand.removeTarget(target)
            commandCenter.pauseCommand.removeTarget(target)
            commandCenter.togglePlayPauseCommand.removeTarget(target)
            commandCenter.nextTrackCommand.removeTarget(target)
            commandCenter.previousTrackCommand.removeTarget(target)
            commandCenter.changePlaybackPositionCommand.removeTarget(target)
        }
        commandTargets.removeAll()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    /// Updates MPNowPlayingInfoCenter with active track metadata and live timing.
    public func updateNowPlaying(
        track: Track?,
        progressMs: Int,
        isPlaying: Bool
    ) {
        guard let track = track else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.name,
            MPMediaItemPropertyArtist: track.artistNamesSummary,
            MPMediaItemPropertyPlaybackDuration: Double(track.durationMs) / 1000.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: Double(progressMs) / 1000.0,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let albumName = track.album?.name {
            info[MPMediaItemPropertyAlbumTitle] = albumName
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        // Fetch artwork in background if URL exists
        if let coverUrlStr = track.album?.coverUrl, let url = URL(string: coverUrlStr) {
            Task.detached(priority: .utility) {
                guard let (data, _) = try? await URLSession.shared.data(from: url),
                      let image = UIImage(data: data) else { return }

                await MainActor.run {
                    var currentInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    currentInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = currentInfo
                }
            }
        }
    }

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        let playTarget = commandCenter.playCommand.addTarget { [weak self] _ in
            self?.onPlayCommand?()
            return .success
        }
        commandTargets.append(playTarget)

        commandCenter.pauseCommand.isEnabled = true
        let pauseTarget = commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.onPauseCommand?()
            return .success
        }
        commandTargets.append(pauseTarget)

        commandCenter.togglePlayPauseCommand.isEnabled = true
        let toggleTarget = commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.onPlayCommand?()
            return .success
        }
        commandTargets.append(toggleTarget)

        commandCenter.nextTrackCommand.isEnabled = true
        let nextTarget = commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.onNextCommand?()
            return .success
        }
        commandTargets.append(nextTarget)

        commandCenter.previousTrackCommand.isEnabled = true
        let prevTarget = commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.onPreviousCommand?()
            return .success
        }
        commandTargets.append(prevTarget)

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        let seekTarget = commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            let positionMs = Int(positionEvent.positionTime * 1000)
            self?.onSeekCommand?(positionMs)
            return .success
        }
        commandTargets.append(seekTarget)
    }
}
