import SwiftUI
import MyspotiDomain

/// Detailed view for an album release, displaying tracklist and hero artwork.
public struct AlbumDetailView: View {
    public let album: Album
    public let tracks: [Track]
    public let onPlayTrack: (Track) -> Void
    public let onPlayAll: () -> Void

    @Environment(\.dismiss) private var dismiss

    public init(
        album: Album,
        tracks: [Track],
        onPlayTrack: @escaping (Track) -> Void,
        onPlayAll: @escaping () -> Void
    ) {
        self.album = album
        self.tracks = tracks
        self.onPlayTrack = onPlayTrack
        self.onPlayAll = onPlayAll
    }

    public var body: some View {
        ZStack {
            Color.amoledBlack.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero Artwork
                    AsyncImage(url: URL(string: album.coverUrl ?? "")) { phase in
                        if case .success(let image) = phase {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Color.surfaceCard
                        }
                    }
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.6), radius: 20, y: 10)
                    .padding(.top, 24)

                    // Album Info
                    VStack(spacing: 6) {
                        Text(album.name)
                            .font(.sectionTitle)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(album.primaryArtistName)
                            .font(.trackArtist)
                            .foregroundColor(.textSecondary)

                        Text("Album • \(album.releaseDate ?? "2026") • \(tracks.count) tracks")
                            .font(.captionTimestamp)
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.horizontal, 24)

                    // Action Bar (Play All Button)
                    HStack(spacing: 16) {
                        Button(action: onPlayAll) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("Play")
                            }
                            .font(.trackTitle)
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.accentGreen)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        Button(action: {}) {
                            Image(systemName: "heart")
                                .font(.system(size: 22))
                                .foregroundColor(.textSecondary)
                                .frame(width: 48, height: 48)
                                .background(Color.surfaceCard)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)

                    // Tracklist
                    VStack(spacing: 8) {
                        ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                            Button(action: { onPlayTrack(track) }) {
                                HStack(spacing: 16) {
                                    Text("\(index + 1)")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textTertiary)
                                        .frame(width: 24, alignment: .leading)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(track.name)
                                            .font(.trackTitle)
                                            .foregroundColor(.textPrimary)
                                            .lineLimit(1)

                                        Text(track.artistNamesSummary)
                                            .font(.captionTimestamp)
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Text(track.formattedDuration)
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textTertiary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 16)

                    Spacer(minLength: 120)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

