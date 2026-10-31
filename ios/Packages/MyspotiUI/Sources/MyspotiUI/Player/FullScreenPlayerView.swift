import SwiftUI
import MyspotiDomain

/// Full-screen Now Playing modal presentation.
public struct FullScreenPlayerView: View {
    public let state: PlaybackState
    public let lyrics: Lyrics?
    public let queue: PlaybackQueue
    public let onDismiss: () -> Void
    public let onPlayPause: () -> Void
    public let onNext: () -> Void
    public let onPrevious: () -> Void
    public let onSeek: (Int) -> Void
    public let onToggleShuffle: () -> Void
    public let onToggleRepeat: () -> Void
    public let onRemoveQueueItem: (String) -> Void
    public let onPlayQueueTrack: (Track) -> Void

    @State private var isShowingLyrics = false
    @State private var isShowingQueue = false
    @State private var dragProgress: Double? = nil

    public init(
        state: PlaybackState,
        lyrics: Lyrics? = nil,
        queue: PlaybackQueue = PlaybackQueue(),
        onDismiss: @escaping () -> Void,
        onPlayPause: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        onSeek: @escaping (Int) -> Void,
        onToggleShuffle: @escaping () -> Void = {},
        onToggleRepeat: @escaping () -> Void = {},
        onRemoveQueueItem: @escaping (String) -> Void = { _ in },
        onPlayQueueTrack: @escaping (Track) -> Void = { _ in }
    ) {
        self.state = state
        self.lyrics = lyrics
        self.queue = queue
        self.onDismiss = onDismiss
        self.onPlayPause = onPlayPause
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.onSeek = onSeek
        self.onToggleShuffle = onToggleShuffle
        self.onToggleRepeat = onToggleRepeat
        self.onRemoveQueueItem = onRemoveQueueItem
        self.onPlayQueueTrack = onPlayQueueTrack
    }

    public var body: some View {
        ZStack {
            // Pitch Black AMOLED Base
            Color.amoledBlack.ignoresSafeArea()

            // Dynamic Ambient Glow
            if let coverUrl = state.currentTrack?.album?.coverUrl {
                AsyncImage(url: URL(string: coverUrl)) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 80)
                            .opacity(0.3)
                            .ignoresSafeArea()
                    }
                }
            }

            VStack(spacing: 24) {
                // Top Header Bar
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    VStack(spacing: 2) {
                        Text("PLAYING AUDIO")
                            .font(.captionTimestamp)
                            .foregroundColor(.textTertiary)
                        Text(state.device?.name ?? "Native Audio")
                            .font(.captionTimestamp)
                            .foregroundColor(.accentGreen)
                    }

                    Spacer()

                    Button(action: { isShowingQueue = true }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)

                Spacer()

                // Hero Album Artwork
                AsyncImage(url: URL(string: state.currentTrack?.album?.coverUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.surfaceCard)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 64))
                                    .foregroundColor(.textTertiary)
                            )
                    }
                }
                .frame(maxWidth: 320, maxHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.6), radius: 24, x: 0, y: 12)

                Spacer()

                // Track Info & Like Action
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(state.currentTrack?.name ?? "No Track Playing")
                            .font(.playerTitle)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)

                        Text(state.currentTrack?.artistNamesSummary ?? "")
                            .font(.playerArtist)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.system(size: 24))
                            .foregroundColor(.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 28)

                // Interactive Scrub Bar
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        let fraction = dragProgress ?? state.progressFraction
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 4)

                            Capsule()
                                .fill(Color.accentGreen)
                                .frame(width: geo.size.width * CGFloat(fraction), height: 4)
                        }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let progress = max(0, min(1, value.location.x / geo.size.width))
                                    dragProgress = progress
                                }
                                .onEnded { value in
                                    let progress = max(0, min(1, value.location.x / geo.size.width))
                                    dragProgress = nil
                                    if let duration = state.currentTrack?.durationMs {
                                        let targetMs = Int(Double(duration) * progress)
                                        onSeek(targetMs)
                                    }
                                }
                        )
                    }
                    .frame(height: 12)

                    HStack {
                        Text(state.formattedProgress)
                            .font(.captionTimestamp)
                            .foregroundColor(.textTertiary)
                        Spacer()
                        Text(state.currentTrack?.formattedDuration ?? "0:00")
                            .font(.captionTimestamp)
                            .foregroundColor(.textTertiary)
                    }
                }
                .padding(.horizontal, 28)

                // Playback Control Cluster
                HStack(spacing: 36) {
                    Button(action: onToggleShuffle) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 20))
                            .foregroundColor(state.shuffleState ? .accentGreen : .textSecondary)
                    }
                    .buttonStyle(.plain)

                    Button(action: onPrevious) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.textPrimary)
                    }
                    .buttonStyle(.plain)

                    Button(action: onPlayPause) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 68, height: 68)

                            Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.black)
                        }
                    }
                    .buttonStyle(.plain)

                    Button(action: onNext) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.textPrimary)
                    }
                    .buttonStyle(.plain)

                    Button(action: onToggleRepeat) {
                        Image(systemName: "repeat")
                            .font(.system(size: 20))
                            .foregroundColor(state.repeatState != .off ? .accentGreen : .textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 8)

                // Bottom Action Dock (Lyrics & Devices)
                HStack {
                    Button(action: { isShowingLyrics.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "music.mic")
                            Text("Lyrics")
                        }
                        .font(.captionTimestamp)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text(state.device?.name ?? "Native Audio")
                    }
                    .font(.captionTimestamp)
                    .foregroundColor(.accentGreen)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $isShowingLyrics) {
            LyricsSheetView(
                lyrics: lyrics,
                currentProgressMs: state.progressMs,
                onSeekToTime: { timeMs in
                    onSeek(timeMs)
                }
            )
        }
        .sheet(isPresented: $isShowingQueue) {
            QueueView(
                queue: queue,
                onRemoveItem: onRemoveQueueItem,
                onPlayTrack: onPlayQueueTrack
            )
        }
    }
}
