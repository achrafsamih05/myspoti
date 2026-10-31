import SwiftUI

/// Typographic hierarchy optimized for iOS music presentation.
public extension Font {
    static let displayLarge = Font.system(size: 32, weight: .bold, design: .rounded)
    static let sectionTitle = Font.system(size: 22, weight: .bold, design: .rounded)
    static let trackTitle = Font.system(size: 16, weight: .semibold, design: .default)
    static let trackArtist = Font.system(size: 14, weight: .regular, design: .default)
    static let playerTitle = Font.system(size: 20, weight: .bold, design: .rounded)
    static let playerArtist = Font.system(size: 16, weight: .medium, design: .default)
    static let captionTimestamp = Font.system(size: 12, weight: .medium, design: .monospaced)
    static let lyricsActive = Font.system(size: 24, weight: .bold, design: .rounded)
    static let lyricsInactive = Font.system(size: 20, weight: .semibold, design: .rounded)
}

