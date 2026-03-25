import SwiftUI

enum AtlasTheme {
    static let bgGradient = LinearGradient(
        colors: [Color(#colorLiteral(red: 0.003, green: 0.031, blue: 0.086, alpha: 1)), Color(#colorLiteral(red: 0.010, green: 0.051, blue: 0.198, alpha: 1))],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelFill = Color.white.opacity(0.06)
    static let panelStroke = Color.white.opacity(0.18)

    static let accent = Color(#colorLiteral(red: 0.294, green: 0.666, blue: 0.964, alpha: 1))
    static let accent2 = Color(#colorLiteral(red: 0.875, green: 0.345, blue: 0.984, alpha: 1))

    static let textPrimary = Color.white
    static let textSecondary = Color(#colorLiteral(red: 0.7, green: 0.75, blue: 0.9, alpha: 1))
}
