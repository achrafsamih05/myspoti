import SwiftUI
import MyspotiDomain

/// Detailed view for an artist profile, top tracks, and discography.
public struct ArtistDetailView: View {
    public let artist: Artist
    public let topTracks: [Track]
    public let albums: [Album]
    public let onPlayTrack: (Track) -> Void
    public let onSelectAlbum: (Album) -> Void

    public init(
        artist: Artist,
        topTracks: [Track],
        albums: [Album],
        onPlayTrack: @escaping (Track) -> Void,
        onSelectAlbum: @escaping (Album) -> Void
    ) {
        self.artist = artist
        self.topTracks = topTracks
        self.albums = albums
        self.onPlayTrack = onPlayTrack
        self.onSelectAlbum = onSelectAlbum
    }

    public var body: some View {
        ZStack {
            Color.amoledBlack.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Artist Avatar Header
                    AsyncImage(url: URL(string: artist.avatarUrl ?? "")) { phase in
                        if case .success(let image) = phase {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            Circle().fill(Color.surfaceCard)
                        }
                    }
                    .frame(width: 180, height: 180)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.6), radius: 20, y: 10)
                    .padding(.top, 24)

                    // Artist Info
                    VStack(spacing: 4) {
                        Text(artist.name)
                            .font(.sectionTitle)
                            .foregroundColor(.textPrimary)

                        if let count = artist.followersCount {
                            Text("\(count / 1000000)M monthly listeners")
                                .font(.captionTimestamp)
                                .foregroundColor(.textSecondary)
                        }

                        if !artist.genres.isEmpty {
                            Text(artist.genres.joined(separator: " • "))
                                .font(.captionTimestamp)
                                .foregroundColor(.accentGreen)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Top Tracks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Popular Tracks")
                            .font(.sectionTitle)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                        ForEach(Array(topTracks.prefix(5).enumerated()), id: \.element.id) { index, track in
                            Button(action: { onPlayTrack(track) }) {
                                HStack(spacing: 14) {
                                    Text("\(index + 1)")
                                        .font(.captionTimestamp)
                                        .foregroundColor(.textTertiary)
                                        .frame(width: 20)

                                    AsyncImage(url: URL(string: track.album?.coverUrl ?? "")) { phase in
                                        if case .success(let image) = phase {
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.surfaceHover
                                        }
                                    }
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(track.name)
                                            .font(.trackTitle)
                                            .foregroundColor(.textPrimary)
                                            .lineLimit(1)

                                        Text(track.formattedDuration)
                                            .font(.captionTimestamp)
                                            .foregroundColor(.textSecondary)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Discography
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Releases")
                            .font(.sectionTitle)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.top, 14)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(albums) { album in
                                    Button(action: { onSelectAlbum(album) }) {
                                        AlbumCardView(album: album)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: 120)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

