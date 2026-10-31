import Foundation

/// Defines official Spotify Web API endpoints conforming strictly to the February 2026 platform specifications.
public enum SpotifyEndpoint {
    case search(query: String)
    case album(id: String)
    case artist(id: String)
    case userPlaylists(limit: Int, offset: Int)
    case playlistItems(playlistId: String, limit: Int, offset: Int)
    case createPlaylist
    case addPlaylistItem(playlistId: String)
    case removePlaylistItem(playlistId: String)
    case libraryContains(uris: [String])
    case libraryAdd
    case libraryRemove
    case playerState
    case playerDevices
    case playerPlay(deviceId: String?)
    case playerPause(deviceId: String?)
    case playerNext(deviceId: String?)
    case playerPrevious(deviceId: String?)
    case playerSeek(positionMs: Int, deviceId: String?)
    case userProfile

    private static let baseURL = "https://api.spotify.com/v1"

    public var url: URL? {
        var components = URLComponents(string: Self.baseURL + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }

    public var method: String {
        switch self {
        case .search, .album, .artist, .userPlaylists, .playlistItems,
             .libraryContains, .playerState, .playerDevices, .userProfile:
            return "GET"
        case .createPlaylist, .addPlaylistItem, .playerNext, .playerPrevious:
            return "POST"
        case .libraryAdd, .playerPlay, .playerPause, .playerSeek:
            return "PUT"
        case .removePlaylistItem, .libraryRemove:
            return "DELETE"
        }
    }

    public var path: String {
        switch self {
        case .search:
            return "/search"
        case .album(let id):
            return "/albums/\(id)"
        case .artist(let id):
            return "/artists/\(id)"
        case .userPlaylists:
            return "/me/playlists"
        case .playlistItems(let id, _, _):
            // 2026 Migration: /tracks -> /items
            return "/playlists/\(id)/items"
        case .createPlaylist:
            return "/me/playlists"
        case .addPlaylistItem(let id), .removePlaylistItem(let id):
            // 2026 Migration: /tracks -> /items
            return "/playlists/\(id)/items"
        case .libraryContains:
            // 2026 Unified Library Endpoint
            return "/me/library/contains"
        case .libraryAdd, .libraryRemove:
            // 2026 Unified Library Endpoint
            return "/me/library"
        case .playerState:
            return "/me/player"
        case .playerDevices:
            return "/me/player/devices"
        case .playerPlay:
            return "/me/player/play"
        case .playerPause:
            return "/me/player/pause"
        case .playerNext:
            return "/me/player/next"
        case .playerPrevious:
            return "/me/player/previous"
        case .playerSeek:
            return "/me/player/seek"
        case .userProfile:
            return "/me"
        }
    }

    public var queryItems: [URLQueryItem] {
        switch self {
        case .search(let query):
            // 2026 Migration: strictly capped at limit 10
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "type", value: "track,album,artist,playlist"),
                URLQueryItem(name: "limit", value: "10")
            ]
        case .userPlaylists(let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: "\(min(limit, 50))"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        case .playlistItems(_, let limit, let offset):
            return [
                URLQueryItem(name: "limit", value: "\(min(limit, 50))"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        case .libraryContains(let uris):
            return [
                URLQueryItem(name: "uris", value: uris.joined(separator: ","))
            ]
        case .playerPlay(let deviceId), .playerPause(let deviceId),
             .playerNext(let deviceId), .playerPrevious(let deviceId):
            guard let id = deviceId else { return [] }
            return [URLQueryItem(name: "device_id", value: id)]
        case .playerSeek(let positionMs, let deviceId):
            var items = [URLQueryItem(name: "position_ms", value: "\(positionMs)")]
            if let id = deviceId {
                items.append(URLQueryItem(name: "device_id", value: id))
            }
            return items
        default:
            return []
        }
    }
}

