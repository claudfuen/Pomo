import Foundation

// Simple helper for timer durations
// Quick starts are now stored via @AppStorage in PresetsView
struct TimerPreset: Identifiable, Equatable {
    let id: UUID
    let minutes: Int
    
    var seconds: Int {
        minutes * 60
    }
    
    init(minutes: Int) {
        self.id = UUID()
        self.minutes = minutes
    }
}
