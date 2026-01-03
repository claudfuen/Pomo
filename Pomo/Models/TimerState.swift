import Foundation

enum TimerState: String, Codable {
    case idle
    case running
    case paused
    case completed
    
    var isActive: Bool {
        self == .running || self == .paused
    }
}


