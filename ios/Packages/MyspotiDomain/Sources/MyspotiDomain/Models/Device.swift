import Foundation

/// Represents a Spotify Connect target playback device.
public struct Device: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let type: String
    public let isActive: Bool
    public let isPrivateSession: Bool
    public let isRestricted: Bool
    public let volumePercent: Int?

    public init(
        id: String,
        name: String,
        type: String,
        isActive: Bool = false,
        isPrivateSession: Bool = false,
        isRestricted: Bool = false,
        volumePercent: Int? = 100
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.isActive = isActive
        self.isPrivateSession = isPrivateSession
        self.isRestricted = isRestricted
        self.volumePercent = volumePercent
    }
}

