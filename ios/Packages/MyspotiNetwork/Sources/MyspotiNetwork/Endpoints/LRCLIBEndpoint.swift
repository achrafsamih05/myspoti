import Foundation

/// Defines public LRCLIB endpoints for retrieving synchronized lyrics.
public enum LRCLIBEndpoint {
    case get(trackName: String, artistName: String, albumName: String?, durationSeconds: Int?)
    case search(query: String)

    private static let baseURL = "https://lrclib.net/api"

    public var url: URL? {
        var components = URLComponents(string: Self.baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }

    public var path: String {
        switch self {
        case .get:
            return "/get"
        case .search:
            return "/search"
        }
    }

    public var queryItems: [URLQueryItem] {
        switch self {
        case .get(let track, let artist, let album, let duration):
            var items = [
                URLQueryItem(name: "track_name", value: track),
                URLQueryItem(name: "artist_name", value: artist)
            ]
            if let album = album, !album.isEmpty {
                items.append(URLQueryItem(name: "album_name", value: album))
            }
            if let duration = duration, duration > 0 {
                items.append(URLQueryItem(name: "duration", value: "\(duration)"))
            }
            return items
        case .search(let query):
            return [URLQueryItem(name: "q", value: query)]
        }
    }
}

