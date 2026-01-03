import SwiftUI

struct TimerRingView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    private let ringSize: CGFloat = 130
    private let lineWidth: CGFloat = 5
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: lineWidth)
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
                .animation(.easeInOut(duration: 0.3), value: timerManager.remainingProgress)
            
            // Center content
            VStack(spacing: 0) {
                Text(timerManager.displayTime)
                    .font(.system(size: 30, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                
                stateLabel
                    .padding(.top, 2)
            }
        }
        .frame(width: ringSize + 16, height: ringSize + 16)
    }
    
    private var ringColor: Color {
        switch timerManager.state {
        case .idle:
            return .teal.opacity(0.6)
        case .running:
            return timerManager.progressColor
        case .paused:
            return .orange
        case .completed:
            return .green
        }
    }
    
    @ViewBuilder
    private var stateLabel: some View {
        switch timerManager.state {
        case .idle:
            Text("Ready")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        case .running:
            HStack(spacing: 4) {
                Circle()
                    .fill(.green)
                    .frame(width: 5, height: 5)
                Text("Running")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        case .paused:
            HStack(spacing: 4) {
                Circle()
                    .fill(.orange)
                    .frame(width: 5, height: 5)
                Text("Paused")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        case .completed:
            Text("Done! 🎉")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    TimerRingView()
        .environmentObject(TimerManager())
        .padding()
}
