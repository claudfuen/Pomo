import Foundation

struct TimerPreset: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let minutes: Int
    let category: Category
    
    enum Category: String, Codable {
        case focus
        case shortBreak
        case longBreak
    }
    
    var seconds: Int {
        minutes * 60
    }
    
    static let defaults: [TimerPreset] = [
        TimerPreset(id: UUID(), name: "Focus", minutes: 25, category: .focus),
        TimerPreset(id: UUID(), name: "Deep Work", minutes: 45, category: .focus),
        TimerPreset(id: UUID(), name: "Short Break", minutes: 5, category: .shortBreak),
        TimerPreset(id: UUID(), name: "Long Break", minutes: 15, category: .longBreak)
    ]
    
    static func custom(minutes: Int) -> TimerPreset {
        TimerPreset(id: UUID(), name: "\(minutes) min", minutes: minutes, category: .focus)
    }
}

