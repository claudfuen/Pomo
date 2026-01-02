import SwiftUI

struct TimerRingView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    @State private var isBreathing = false
    @State private var isPulsing = false
    @State private var showCompletion = false
    
    private let ringSize: CGFloat = 160
    private let lineWidth: CGFloat = 10
    
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
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: timerManager.remainingProgress)
            
            // Glow effect at progress end
            if timerManager.state == .running && timerManager.remainingProgress > 0.01 {
                Circle()
                    .fill(timerManager.progressColor.opacity(0.6))
                    .frame(width: lineWidth * 2, height: lineWidth * 2)
                    .blur(radius: 6)
                    .offset(y: -ringSize / 2)
                    .rotationEffect(.degrees(360 * timerManager.remainingProgress - 90))
                    .animation(.linear(duration: 0.3), value: timerManager.remainingProgress)
            }
            
            // Center content
            VStack(spacing: 4) {
                // Time display
                Text(timerManager.displayTime)
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(Color.theme.text)
                    .accessibilityLabel("Time remaining: \(timerManager.displayTime)")
                
                // State indicator
                stateIndicator
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    timerManager.toggle()
                }
            }
            .accessibilityHint("Tap to \(timerManager.state == .running ? "pause" : "start") timer")
            
            // Completion animation
            if showCompletion {
                Circle()
                    .stroke(Color.theme.timerComplete, lineWidth: lineWidth)
                    .frame(width: ringSize, height: ringSize)
                    .scaleEffect(isPulsing ? 1.15 : 1.0)
                    .opacity(isPulsing ? 0 : 1)
            }
        }
        .frame(width: ringSize + 20, height: ringSize + 20)
        .onChange(of: timerManager.state) { oldState, newState in
            handleStateChange(from: oldState, to: newState)
        }
        .onAppear {
            if timerManager.state == .paused {
                startBreathingAnimation()
            }
        }
    }
    
    @ViewBuilder
    private var stateIndicator: some View {
        switch timerManager.state {
        case .idle:
            Text("Tap to start")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .running:
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.theme.timerActive)
                    .frame(width: 6, height: 6)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                Text("Running")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .onAppear { isPulsing = true }
            .onDisappear { isPulsing = false }
        case .paused:
            HStack(spacing: 4) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.theme.timerWarning)
                Text("Paused")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .opacity(isBreathing ? 0.5 : 1.0)
        case .completed:
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.theme.timerComplete)
                Text("Complete!")
                    .font(.caption)
                    .foregroundStyle(Color.theme.timerComplete)
            }
        }
    }
    
    private func handleStateChange(from oldState: TimerState, to newState: TimerState) {
        // Reset animations
        isBreathing = false
        isPulsing = false
        showCompletion = false
        
        switch newState {
        case .paused:
            startBreathingAnimation()
        case .running:
            isPulsing = true
        case .completed:
            triggerCompletionAnimation()
        case .idle:
            break
        }
    }
    
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            isBreathing = true
        }
    }
    
    private func triggerCompletionAnimation() {
        showCompletion = true
        isPulsing = false
        
        withAnimation(.easeOut(duration: 0.6)) {
            isPulsing = true
        }
        
        // Reset for next time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            showCompletion = false
            isPulsing = false
        }
    }
}

#Preview {
    TimerRingView()
        .environmentObject(TimerManager())
        .padding()
}
