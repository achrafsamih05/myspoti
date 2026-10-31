import SwiftUI
import MyspotiDomain

/// Home view featuring editorial shelves and AMOLED cards.
public struct HomeView: View {
    public let albums: [Album]
    public let playlists: [Playlist]
    public let onSelectAlbum: (Album) -> Void
    public let onSelectPlaylist: (Playlist) -> Void
    public let onPlayTrack: (Track) -> Void

    public init(
        albums: [Album],
        playlists: [Playlist],
        onSelectAlbum: @escaping (Album) -> Void,
        onSelectPlaylist: @escaping (Playlist) -> Void,
        onPlayTrack: @escaping (Track) -> Void
    ) {
        self.albums = albums
        self.playlists = playlists
        self.onSelectAlbum = onSelectAlbum
        self.onSelectPlaylist = onSelectPlaylist
        self.onPlayTrack = onPlayTrack
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.amoledBlack.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        // Header Greeting
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greetingMessage)
                                .font(.displayLarge)
                                .foregroundColor(.textPrimary)
                            Text("Welcome to Myspoti")
                                .font(.trackArtist)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Featured Playlists Shelf
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Featured Playlists")
                                .font(.sectionTitle)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(playlists) { playlist in
                                        Button(action: { onSelectPlaylist(playlist) }) {
                                            PlaylistCardView(playlist: playlist)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // Recent Releases Shelf
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Albums & Releases")
                                .font(.sectionTitle)
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 20)

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
            .navigationBarHidden(true)
        }
    }

    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}

struct PlaylistCardView: View {
    let playlist: Playlist

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: playlist.coverUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.surfaceCard)
                        .overlay(Image(systemName: "music.note.list").foregroundColor(.textTertiary))
                }
            }
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(playlist.name)
                .font(.trackTitle)
                .foregroundColor(.textPrimary)
                .lineLimit(1)
                .frame(width: 150, alignment: .leading)

            Text(playlist.description ?? "\(playlist.totalItems) items")
                .font(.captionTimestamp)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
                .frame(width: 150, alignment: .leading)
        }
    }
}

struct AlbumCardView: View {
    let album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: album.coverUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.surfaceCard)
                        .overlay(Image(systemName: "opticaldisc").foregroundColor(.textTertiary))
                }
            }
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(album.name)
                .font(.trackTitle)
                .foregroundColor(.textPrimary)
                .lineLimit(1)
                .frame(width: 150, alignment: .leading)

            Text(album.primaryArtistName)
                .font(.captionTimestamp)
                .foregroundColor(.textSecondary)
                .lineLimit(1)
                .frame(width: 150, alignment: .leading)
        }
    }
}

