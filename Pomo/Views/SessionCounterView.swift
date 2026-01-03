import SwiftUI

struct SessionCounterView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    // Cap visible dots at 8 to prevent overflow
    private var visibleDots: Int {
        min(max(timerManager.sessionsToday, 1), 8)
    }
    
    private var hasMoreSessions: Bool {
        timerManager.sessionsToday > 8
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Session dots (max 8)
            ForEach(0..<visibleDots, id: \.self) { index in
                Circle()
                    .fill(index < timerManager.sessionsToday ? Color.theme.timerComplete : Color.theme.ringBackground)
                    .frame(width: 8, height: 8)
            }
            
            // Overflow indicator
            if hasMoreSessions {
                Text("+\(timerManager.sessionsToday - 8)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.theme.timerComplete)
            }
            
            // Session label
            if timerManager.sessionsToday > 0 {
                Text("Session #\(timerManager.sessionsToday)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            } else {
                Text("No sessions yet")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .accessibilityLabel("\(timerManager.sessionsToday) sessions completed today")
    }
}

#Preview {
    VStack(spacing: 20) {
        SessionCounterView()
            .environmentObject(TimerManager())
    }
    .padding()
}
