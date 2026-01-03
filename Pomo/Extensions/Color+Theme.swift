import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Single accent color - teal
    let accent = Color.teal
    
    // Timer states - use system semantic colors
    let timerActive = Color.teal
    let timerWarning = Color.orange
    let timerUrgent = Color.red
    let timerComplete = Color.green
    
    // UI colors - all system adaptive
    let text = Color.primary
    let secondaryText = Color.secondary
    let tertiaryText = Color(NSColor.tertiaryLabelColor)
    
    // Presets - simple
    let focusPreset = Color.teal
    let breakPreset = Color.purple
    
    // Ring - subtle
    let ringBackground = Color.secondary.opacity(0.2)
    
    // For backwards compatibility
    var primary: Color { accent }
    var primaryLight: Color { accent }
    var primaryDark: Color { accent }
    var background: Color { Color(NSColor.windowBackgroundColor) }
    var secondaryBackground: Color { Color.secondary.opacity(0.1) }
}

