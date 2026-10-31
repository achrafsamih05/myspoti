import SwiftUI
import MyspotiDomain

/// User Library view displaying saved tracks and playlists conforming to 2026 unified library contracts.
public struct LibraryView: View {
    public let playlists: [Playlist]
    public let savedTracksCount: Int
    public let onSelectPlaylist: (Playlist) -> Void
    public let onOpenLikedSongs: () -> Void

    public init(
        playlists: [Playlist],
        savedTracksCount: Int,
        onSelectPlaylist: @escaping (Playlist) -> Void,
        onOpenLikedSongs: @escaping () -> Void
    ) {
        self.playlists = playlists
        self.savedTracksCount = savedTracksCount
        self.onSelectPlaylist = onSelectPlaylist
        self.onOpenLikedSongs = onOpenLikedSongs
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.amoledBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text("Your Library")
                            .font(.displayLarge)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        // Liked Songs Hero Card
                        Button(action: onOpenLikedSongs) {
                            HStack(spacing: 16) {
                                ZStack {
                                    LinearGradient(
                                        colors: [Color(hex: "450af5"), Color(hex: "8e8ee5")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Liked Songs")
                                        .font(.sectionTitle)
                                        .foregroundColor(.textPrimary)
                                    Text("\(savedTracksCount) saved tracks")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.textTertiary)
                            }
                            .padding(14)
                            .background(Color.surfaceCard)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)

                        // User Playlists Section
                        Text("Playlists (\(playlists.count))")
                            .font(.sectionTitle)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                        LazyVStack(spacing: 12) {
                            ForEach(playlists) { playlist in
                                Button(action: { onSelectPlaylist(playlist) }) {
                                    HStack(spacing: 14) {
                                        AsyncImage(url: URL(string: playlist.coverUrl ?? "")) { phase in
                                            if case .success(let image) = phase {
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            } else {
                                                Color.surfaceHover
                                            }
                                        }
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(playlist.name)
                                                .font(.trackTitle)
                                                .foregroundColor(.textPrimary)
                                                .lineLimit(1)

                                            Text("Playlist • \(playlist.totalItems) items")
                                                .font(.captionTimestamp)
                                                .foregroundColor(.textSecondary)
                                        }

                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

