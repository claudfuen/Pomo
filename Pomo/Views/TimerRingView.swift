import SwiftUI

struct TimerRingView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    private let ringSize: CGFloat = 120
    private let lineWidth: CGFloat = 4
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.secondary.opacity(0.12), lineWidth: lineWidth)
                .frame(width: ringSize, height: ringSize)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: timerManager.remainingProgress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.3), value: timerManager.remainingProgress)
            
            // Time display
            Text(timerManager.displayTime)
                .font(.system(size: 28, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .frame(width: ringSize + 12, height: ringSize + 12)
    }
    
    private var ringColor: Color {
        switch timerManager.state {
        case .idle:
            return .teal.opacity(0.5)
        case .running:
            return timerManager.progressColor
        case .paused:
            return .orange
        case .completed:
            return .green
        }
    }
}

#Preview {
    TimerRingView()
        .environmentObject(TimerManager())
        .padding()
}
