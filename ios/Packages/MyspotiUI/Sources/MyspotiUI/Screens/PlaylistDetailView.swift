import SwiftUI
import MyspotiDomain

/// Detailed view for a playlist with item rows complying with 2026 specifications.
public struct PlaylistDetailView: View {
    public let playlist: Playlist
    public let items: [PlaylistItem]
    public let onPlayTrack: (Track) -> Void
    public let onPlayAll: () -> Void

    public init(
        playlist: Playlist,
        items: [PlaylistItem],
        onPlayTrack: @escaping (Track) -> Void,
        onPlayAll: @escaping () -> Void
    ) {
        self.playlist = playlist
        self.items = items
        self.onPlayTrack = onPlayTrack
        self.onPlayAll = onPlayAll
    }

    public var body: some View {
        ZStack {
            Color.amoledBlack.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero Cover Art
                    AsyncImage(url: URL(string: playlist.coverUrl ?? "")) { phase in
                        if case .success(let image) = phase {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            RoundedRectangle(cornerRadius: 16).fill(Color.surfaceCard)
                        }
                    }
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.6), radius: 20, y: 10)
                    .padding(.top, 24)

                    // Playlist Info
                    VStack(spacing: 6) {
                        Text(playlist.name)
                            .font(.sectionTitle)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)

                        if let desc = playlist.description {
                            Text(desc)
                                .font(.trackArtist)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }

                        Text("By \(playlist.ownerName ?? "Myspoti") • \(items.count) items")
                            .font(.captionTimestamp)
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.horizontal, 24)

                    // Play Button Bar
                    Button(action: onPlayAll) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Play All")
                        }
                        .font(.trackTitle)
                        .foregroundColor(.black)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(Color.accentGreen)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)

                    // Item rows
                    VStack(spacing: 8) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            Button(action: { onPlayTrack(item.track) }) {
                                HStack(spacing: 14) {
                                    Text("\(index + 1)")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textTertiary)
                                        .frame(width: 20)

                                    AsyncImage(url: URL(string: item.track.album?.coverUrl ?? "")) { phase in
                                        if case .success(let image) = phase {
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.surfaceHover
                                        }
                                    }
                                    .frame(width: 46, height: 46)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.track.name)
                                            .font(.trackTitle)
                                            .foregroundColor(.textPrimary)
                                            .lineLimit(1)

                                        Text(item.track.artistNamesSummary)
                                            .font(.captionTimestamp)
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Text(item.track.formattedDuration)
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textTertiary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 12)

                    Spacer(minLength: 120)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

