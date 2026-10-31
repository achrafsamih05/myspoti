import SwiftUI
import MyspotiDomain

/// Root application shell integrating tab navigation, detail destinations, floating mini-player, and full player sheet.
public struct RootNavigationView: View {
    public let catalogRepository: CatalogRepositoryProtocol
    public let libraryRepository: LibraryRepositoryProtocol
    public let playbackRepository: PlaybackRepositoryProtocol
    public let lyricsRepository: LyricsRepositoryProtocol

    @State private var selectedTab: Int = 0
    @State private var playbackState: PlaybackState = PlaybackState()
    @State private var currentLyrics: Lyrics? = nil
    @State private var currentQueue: PlaybackQueue = PlaybackQueue()
    @State private var isFullScreenPresented: Bool = false
    @State private var sampleAlbums: [Album] = []
    @State private var samplePlaylists: [Playlist] = []

    // Navigation Destinations with loaded sub-items
    @State private var selectedAlbum: Album? = nil
    @State private var selectedAlbumTracks: [Track] = []
    @State private var selectedPlaylist: Playlist? = nil
    @State private var selectedPlaylistItems: [PlaylistItem] = []

    public init(
        catalogRepository: CatalogRepositoryProtocol,
        libraryRepository: LibraryRepositoryProtocol,
        playbackRepository: PlaybackRepositoryProtocol,
        lyricsRepository: LyricsRepositoryProtocol
    ) {
        self.catalogRepository = catalogRepository
        self.libraryRepository = libraryRepository
        self.playbackRepository = playbackRepository
        self.lyricsRepository = lyricsRepository
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab View
            TabView(selection: $selectedTab) {
                // Tab 0: Home
                NavigationStack {
                    HomeView(
                        albums: sampleAlbums,
                        playlists: samplePlaylists,
                        onSelectAlbum: { album in
                            Task {
                                selectedAlbumTracks = (try? await catalogRepository.getAlbumTracks(albumId: album.id)) ?? []
                                selectedAlbum = album
                            }
                        },
                        onSelectPlaylist: { playlist in
                            Task {
                                selectedPlaylistItems = (try? await libraryRepository.getPlaylistItems(playlistId: playlist.id)) ?? []
                                selectedPlaylist = playlist
                            }
                        },
                        onPlayTrack: { track in
                            Task { try? await playbackRepository.playTrack(track) }
                        }
                    )
                    .navigationDestination(item: $selectedAlbum) { album in
                        AlbumDetailView(
                            album: album,
                            tracks: selectedAlbumTracks,
                            onPlayTrack: { track in
                                Task { try? await playbackRepository.playTrack(track) }
                            },
                            onPlayAll: {
                                if let first = selectedAlbumTracks.first {
                                    Task { try? await playbackRepository.playTrack(first) }
                                }
                            }
                        )
                    }
                    .navigationDestination(item: $selectedPlaylist) { playlist in
                        PlaylistDetailView(
                            playlist: playlist,
                            items: selectedPlaylistItems,
                            onPlayTrack: { track in
                                Task { try? await playbackRepository.playTrack(track) }
                            },
                            onPlayAll: {
                                if let first = selectedPlaylistItems.first?.track {
                                    Task { try? await playbackRepository.playTrack(first) }
                                }
                            }
                        )
                    }
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

                // Tab 1: Search
                NavigationStack {
                    SearchView(
                        onSearch: { query in
                            (try? await catalogRepository.search(query: query, limit: 10)) ?? SearchResults()
                        },
                        onPlayTrack: { track in
                            Task { try? await playbackRepository.playTrack(track) }
                        }
                    )
                }
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)

                // Tab 2: Library
                NavigationStack {
                    LibraryView(
                        playlists: samplePlaylists,
                        savedTracksCount: samplePlaylists.reduce(0) { $0 + $1.totalItems },
                        onSelectPlaylist: { playlist in
                            Task {
                                selectedPlaylistItems = (try? await libraryRepository.getPlaylistItems(playlistId: playlist.id)) ?? []
                                selectedPlaylist = playlist
                            }
                        },
                        onOpenLikedSongs: {
                            if let first = samplePlaylists.first {
                                Task {
                                    selectedPlaylistItems = (try? await libraryRepository.getPlaylistItems(playlistId: first.id)) ?? []
                                    selectedPlaylist = first
                                }
                            }
                        }
                    )
                    .navigationDestination(item: $selectedPlaylist) { playlist in
                        PlaylistDetailView(
                            playlist: playlist,
                            items: selectedPlaylistItems,
                            onPlayTrack: { track in
                                Task { try? await playbackRepository.playTrack(track) }
                            },
                            onPlayAll: {
                                if let first = selectedPlaylistItems.first?.track {
                                    Task { try? await playbackRepository.playTrack(first) }
                                }
                            }
                        )
                    }
                }
                .tabItem {
                    Label("Your Library", systemImage: "books.vertical.fill")
                }
                .tag(2)

                // Tab 3: Settings & Status
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)

                // Tab 4: Profile
                ProfileView(
                    user: UserProfile(
                        id: "user_free_owner",
                        uri: "myspoti:user:free_local",
                        displayName: "Personal iPhone User",
                        email: "user@myspoti.free",
                        product: "free"
                    ),
                    onSignOut: {}
                )
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(4)
            }
            .accentColor(.accentGreen)

            // Floating Mini-Player (Docked above bottom tab bar)
            if playbackState.currentTrack != nil {
                MiniPlayerView(
                    state: playbackState,
                    onPlayPause: {
                        Task {
                            if playbackState.isPlaying {
                                try? await playbackRepository.pause()
                            } else {
                                try? await playbackRepository.resume()
                            }
                        }
                    },
                    onSkipNext: {
                        Task { try? await playbackRepository.next() }
                    },
                    onTapExpand: {
                        isFullScreenPresented = true
                    }
                )
                .padding(.bottom, 54) // Offset for tab bar
            }
        }
        .task {
            // Initial load of content
            samplePlaylists = (try? await libraryRepository.getUserPlaylists(limit: 10, offset: 0)) ?? []
            sampleAlbums = [
                (try? await catalogRepository.getAlbum(id: "alb1")),
                (try? await catalogRepository.getAlbum(id: "alb2"))
            ].compactMap { $0 }

            // Observe playback state stream
            for await state in playbackRepository.observePlaybackState() {
                self.playbackState = state
                self.currentQueue = await playbackRepository.getQueue()

                if let track = state.currentTrack {
                    // Load synchronized lyrics from LRCLIB or mock provider
                    self.currentLyrics = try? await lyricsRepository.getLyrics(
                        trackName: track.name,
                        artistName: track.artists.first?.name ?? "",
                        albumName: track.album?.name,
                        durationSeconds: track.durationMs / 1000
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $isFullScreenPresented) {
            FullScreenPlayerView(
                state: playbackState,
                lyrics: currentLyrics,
                queue: currentQueue,
                onDismiss: { isFullScreenPresented = false },
                onPlayPause: {
                    Task {
                        if playbackState.isPlaying {
                            try? await playbackRepository.pause()
                        } else {
                            try? await playbackRepository.resume()
                        }
                    }
                },
                onNext: {
                    Task { try? await playbackRepository.next() }
                },
                onPrevious: {
                    Task { try? await playbackRepository.previous() }
                },
                onSeek: { positionMs in
                    Task { try? await playbackRepository.seek(positionMs: positionMs) }
                },
                onToggleShuffle: {
                    Task { try? await playbackRepository.toggleShuffle() }
                },
                onToggleRepeat: {
                    Task { try? await playbackRepository.toggleRepeat() }
                },
                onRemoveQueueItem: { trackId in
                    Task {
                        await playbackRepository.removeFromQueue(trackId: trackId)
                        self.currentQueue = await playbackRepository.getQueue()
                    }
                },
                onPlayQueueTrack: { track in
                    Task { try? await playbackRepository.playTrack(track) }
                }
            )
        }
    }
}
