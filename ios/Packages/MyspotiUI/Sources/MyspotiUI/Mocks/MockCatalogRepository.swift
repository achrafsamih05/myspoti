import Foundation
import MyspotiDomain

/// Mock catalog repository delivering verified, legally licensed test music data.
/// Audio Source: SoundHelix (Created by Thomas Schürger)
/// License: Creative Commons Attribution 4.0 International (CC BY 4.0)
/// Attribution Notice: Audio files provided by SoundHelix (https://www.soundhelix.com) under CC BY 4.0.
public final class MockCatalogRepository: CatalogRepositoryProtocol, @unchecked Sendable {
    public init() {}

    public func search(query: String, limit: Int) async throws -> SearchResults {
        // Enforce February 2026 search limit of 10 items
        let effectiveLimit = min(limit, 10)
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        let matchedTracks: [Track]
        if trimmed.isEmpty {
            matchedTracks = Self.sampleTracks
        } else {
            matchedTracks = Self.sampleTracks.filter {
                $0.name.localizedCaseInsensitiveContains(trimmed) ||
                $0.artistNamesSummary.localizedCaseInsensitiveContains(trimmed)
            }
        }

        return SearchResults(
            tracks: Array(matchedTracks.prefix(effectiveLimit)),
            albums: Array(Self.sampleAlbums.prefix(effectiveLimit)),
            artists: Array(Self.sampleArtists.prefix(effectiveLimit)),
            playlists: Array(Self.samplePlaylists.prefix(effectiveLimit))
        )
    }

    public func getAlbum(id: String) async throws -> Album {
        Self.sampleAlbums.first { $0.id == id } ?? Self.sampleAlbums[0]
    }

    public func getAlbumTracks(albumId: String) async throws -> [Track] {
        if albumId == "alb2" {
            return Array(Self.sampleTracks.suffix(2))
        }
        return Array(Self.sampleTracks.prefix(2))
    }

    public func getArtist(id: String) async throws -> Artist {
        Self.sampleArtists.first { $0.id == id } ?? Self.sampleArtists[0]
    }

    // MARK: - Verified Creative Commons CC BY 4.0 Test Media

    public static let sampleTracks: [Track] = [
        Track(
            id: "helix_track_1",
            uri: "myspoti:track:soundhelix_1",
            name: "SoundHelix Song 1 (Ambient Chill)",
            durationMs: 372000, // 6:12
            artists: [ArtistReference(id: "sh_artist", uri: "myspoti:artist:soundhelix", name: "Thomas Schürger (CC BY 4.0)")],
            album: AlbumReference(
                id: "alb1",
                uri: "myspoti:album:soundscapes_1",
                name: "Algorithmic Soundscapes Vol. 1",
                images: [ImageReference(url: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80")]
            ),
            explicit: false,
            isPlayable: true,
            previewUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            audioStreamUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
        ),
        Track(
            id: "helix_track_2",
            uri: "myspoti:track:soundhelix_2",
            name: "SoundHelix Song 2 (Electronic Groove)",
            durationMs: 423000, // 7:03
            artists: [ArtistReference(id: "sh_artist", uri: "myspoti:artist:soundhelix", name: "Thomas Schürger (CC BY 4.0)")],
            album: AlbumReference(
                id: "alb1",
                uri: "myspoti:album:soundscapes_1",
                name: "Algorithmic Soundscapes Vol. 1",
                images: [ImageReference(url: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80")]
            ),
            explicit: false,
            isPlayable: true,
            previewUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
            audioStreamUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"
        ),
        Track(
            id: "helix_track_3",
            uri: "myspoti:track:soundhelix_3",
            name: "SoundHelix Song 3 (Arpeggiated Wave)",
            durationMs: 343000, // 5:43
            artists: [ArtistReference(id: "sh_artist", uri: "myspoti:artist:soundhelix", name: "Thomas Schürger (CC BY 4.0)")],
            album: AlbumReference(
                id: "alb2",
                uri: "myspoti:album:soundscapes_2",
                name: "Algorithmic Soundscapes Vol. 2",
                images: [ImageReference(url: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80")]
            ),
            explicit: false,
            isPlayable: true,
            previewUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
            audioStreamUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"
        ),
        Track(
            id: "helix_track_4",
            uri: "myspoti:track:soundhelix_4",
            name: "SoundHelix Song 4 (Piano & Synth)",
            durationMs: 302000, // 5:02
            artists: [ArtistReference(id: "sh_artist", uri: "myspoti:artist:soundhelix", name: "Thomas Schürger (CC BY 4.0)")],
            album: AlbumReference(
                id: "alb2",
                uri: "myspoti:album:soundscapes_2",
                name: "Algorithmic Soundscapes Vol. 2",
                images: [ImageReference(url: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80")]
            ),
            explicit: false,
            isPlayable: true,
            previewUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
            audioStreamUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3"
        )
    ]

    public static let sampleAlbums: [Album] = [
        Album(
            id: "alb1",
            uri: "myspoti:album:soundscapes_1",
            name: "Algorithmic Soundscapes Vol. 1",
            artists: [ArtistReference(id: "sh_artist", uri: "myspoti:artist:soundhelix", name: "Thomas Schürger (CC BY 4.0)")],
            images: [ImageReference(url: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80")],
            releaseDate: "2024",
            totalTracks: 2,
            albumType: "album"
        ),
        Album(
            id: "alb2",
            uri: "myspoti:album:soundscapes_2",
            name: "Algorithmic Soundscapes Vol. 2",
            artists: [ArtistReference(id: "sh_artist", uri: "myspoti:artist:soundhelix", name: "Thomas Schürger (CC BY 4.0)")],
            images: [ImageReference(url: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80")],
            releaseDate: "2025",
            totalTracks: 2,
            albumType: "album"
        )
    ]

    public static let sampleArtists: [Artist] = [
        Artist(
            id: "sh_artist",
            uri: "myspoti:artist:soundhelix",
            name: "Thomas Schürger (SoundHelix)",
            images: [ImageReference(url: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80")],
            genres: ["algorithmic composition", "ambient", "creative commons"],
            followersCount: 15400
        )
    ]

    public static let samplePlaylists: [Playlist] = [
        Playlist(
            id: "p1",
            uri: "myspoti:playlist:open_ambient",
            name: "Creative Commons Ambient",
            description: "Authorized open-source algorithmic compositions. CC BY 4.0.",
            ownerName: "Myspoti Free Lab",
            images: [ImageReference(url: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80")],
            totalItems: 4
        ),
        Playlist(
            id: "p2",
            uri: "myspoti:playlist:focus_session",
            name: "Focus & Flow (Free Audio)",
            description: "Deep focus audio streams licensed for legal personal playback.",
            ownerName: "Myspoti Free Lab",
            images: [ImageReference(url: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80")],
            totalItems: 4
        )
    ]
}
