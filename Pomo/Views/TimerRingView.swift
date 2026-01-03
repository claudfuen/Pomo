import SwiftUI

struct TimerRingView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    private let ringSize: CGFloat = 160
    private let lineWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.theme.ringBackground, lineWidth: lineWidth)
                .frame(width: ringSize, height: ringSize)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: timerManager.remainingProgress)
                .stroke(
                    timerManager.progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: timerManager.remainingProgress)
            
            // Center content
            VStack(spacing: 4) {
                Text(timerManager.displayTime)
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                
                stateIndicator
            }
            .contentShape(Rectangle())
            .onTapGesture {
                timerManager.toggle()
            }
        }
        .frame(width: ringSize + 20, height: ringSize + 20)
    }
    
    @ViewBuilder
    private var stateIndicator: some View {
        switch timerManager.state {
        case .idle:
            Text("Tap to start")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .running:
            Text("Running")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .paused:
            Text("Paused")
                .font(.caption)
                .foregroundStyle(.orange)
        case .completed:
            Text("Done!")
                .font(.caption)
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    TimerRingView()
        .environmentObject(TimerManager())
        .padding()
}
