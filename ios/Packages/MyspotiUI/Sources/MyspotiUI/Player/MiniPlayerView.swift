import SwiftUI
import MyspotiDomain

/// Interactive floating mini-player docked above the tab bar.
public struct MiniPlayerView: View {
    public let state: PlaybackState
    public let onPlayPause: () -> Void
    public let onSkipNext: () -> Void
    public let onTapExpand: () -> Void

    public init(
        state: PlaybackState,
        onPlayPause: @escaping () -> Void,
        onSkipNext: @escaping () -> Void,
        onTapExpand: @escaping () -> Void
    ) {
        self.state = state
        self.onPlayPause = onPlayPause
        self.onSkipNext = onSkipNext
        self.onTapExpand = onTapExpand
    }

    public var body: some View {
        if let track = state.currentTrack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Album Artwork
                    AsyncImage(url: URL(string: track.album?.coverUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.surfaceHover)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .foregroundColor(.textTertiary)
                                )
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    // Track Title & Artist
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.name)
                            .font(.trackTitle)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)

                        Text(track.artistNamesSummary)
                            .font(.trackArtist)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Play/Pause Action Button
                    Button(action: onPlayPause) {
                        Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.textPrimary)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)

                    // Skip Next Button
                    Button(action: onSkipNext) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.textSecondary)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                // 2pt Progress Bar Accent Line
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 2)

                        Rectangle()
                            .fill(Color.accentGreen)
                            .frame(width: geo.size.width * CGFloat(state.progressFraction), height: 2)
                    }
                }
                .frame(height: 2)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTapExpand)
        }
    }
}

