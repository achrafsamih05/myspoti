import SwiftUI

/// AMOLED Dark Theme design tokens.
public extension Color {
    static let amoledBlack = Color.black // #000000 true black
    static let surfaceElevated = Color(hex: "121212")
    static let surfaceCard = Color(hex: "181818")
    static let surfaceHover = Color(hex: "242424")
    static let accentGreen = Color(hex: "1DB954") // Spotify signature green
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "B3B3B3")
    static let textTertiary = Color(hex: "727272")
    static let errorRed = Color(hex: "E91429")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

