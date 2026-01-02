import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Primary brand color - deep teal
    let primary = Color(hex: "0D9488")
    let primaryLight = Color(hex: "14B8A6")
    let primaryDark = Color(hex: "0F766E")
    
    // Timer states
    let timerActive = Color(hex: "0D9488")    // Teal
    let timerWarning = Color(hex: "F59E0B")   // Amber
    let timerUrgent = Color(hex: "EF4444")    // Red
    let timerComplete = Color(hex: "10B981")  // Emerald
    
    // UI colors
    let background = Color(NSColor.windowBackgroundColor)
    let secondaryBackground = Color(NSColor.controlBackgroundColor)
    let text = Color(NSColor.labelColor)
    let secondaryText = Color(NSColor.secondaryLabelColor)
    let tertiaryText = Color(NSColor.tertiaryLabelColor)
    
    // Preset categories
    let focusPreset = Color(hex: "0D9488")
    let breakPreset = Color(hex: "8B5CF6")
    
    // Ring colors
    let ringBackground = Color(NSColor.separatorColor).opacity(0.3)
}

extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
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

