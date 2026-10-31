import SwiftUI
import MyspotiDomain

/// Catalog search view strictly adhering to Spotify's February 2026 10-result limit.
public struct SearchView: View {
    public let onSearch: (String) async -> SearchResults
    public let onPlayTrack: (Track) -> Void

    @State private var query: String = ""
    @State private var results: SearchResults = SearchResults()
    @State private var isLoading: Bool = false

    public init(
        onSearch: @escaping (String) async -> SearchResults,
        onPlayTrack: @escaping (Track) -> Void
    ) {
        self.onSearch = onSearch
        self.onPlayTrack = onPlayTrack
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.amoledBlack.ignoresSafeArea()

                VStack(spacing: 16) {
                    // Search Bar Input
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textSecondary)

                        TextField("Search tracks, artists, albums...", text: $query)
                            .foregroundColor(.textPrimary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onChange(of: query) { _, newQuery in
                                Task { await performSearch(newQuery) }
                            }

                        if !query.isEmpty {
                            Button(action: { query = ""; results = SearchResults() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.textTertiary)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Notice of 2026 API Constraint
                    HStack {
                        Image(systemName: "info.circle")
                        Text("Search results capped at 10 items per Spotify 2026 API policy.")
                    }
                    .font(.captionTimestamp)
                    .foregroundColor(.textTertiary)
                    .padding(.horizontal, 20)

                    // Results List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            if !results.tracks.isEmpty {
                                Text("Top Songs (\(results.tracks.count))")
                                    .font(.sectionTitle)
                                    .foregroundColor(.textPrimary)
                                    .padding(.top, 8)

                                ForEach(results.tracks) { track in
                                    TrackRowView(track: track) {
                                        onPlayTrack(track)
                                    }
                                }
                            }

                            if !results.albums.isEmpty {
                                Text("Albums (\(results.albums.count))")
                                    .font(.sectionTitle)
                                    .foregroundColor(.textPrimary)
                                    .padding(.top, 16)

                                ForEach(results.albums) { album in
                                    AlbumRowView(album: album)
                                }
                            }

                            if !results.artists.isEmpty {
                                Text("Artists (\(results.artists.count))")
                                    .font(.sectionTitle)
                                    .foregroundColor(.textPrimary)
                                    .padding(.top, 16)

                                ForEach(results.artists) { artist in
                                    ArtistRowView(artist: artist)
                                }
                            }

                            Spacer(minLength: 120)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func performSearch(_ query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = SearchResults()
            return
        }
        isLoading = true
        let fetched = await onSearch(query)
        await MainActor.run {
            self.results = fetched
            self.isLoading = false
        }
    }
}

struct TrackRowView: View {
    let track: Track
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: track.album?.coverUrl ?? "")) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Color.surfaceHover
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
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

                Text(track.formattedDuration)
                    .font(.captionTimestamp)
                    .foregroundColor(.textTertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct AlbumRowView: View {
    let album: Album

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: album.coverUrl ?? "")) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color.surfaceHover
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(album.name)
                    .font(.trackTitle)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                Text(album.primaryArtistName)
                    .font(.trackArtist)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ArtistRowView: View {
    let artist: Artist

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: artist.avatarUrl ?? "")) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Color.surfaceHover
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(artist.name)
                    .font(.trackTitle)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                Text("Artist")
                    .font(.captionTimestamp)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

