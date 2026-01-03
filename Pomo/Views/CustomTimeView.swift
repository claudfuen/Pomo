import SwiftUI

struct CustomTimeView: View {
    @EnvironmentObject var timerManager: TimerManager
    @AppStorage("customMinutes") private var customMinutes: Double = 25
    
    var body: some View {
        VStack(spacing: 12) {
            // Time display
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(customMinutes))")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.theme.primary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: Int(customMinutes))
                
                Text("min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.theme.secondaryText)
            }
            .accessibilityLabel("\(Int(customMinutes)) minutes")
            
            // Slider
            HStack(spacing: 12) {
                Text("1")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                Slider(value: $customMinutes, in: 1...120, step: 1)
                    .tint(Color.theme.primary)
                    .accessibilityLabel("Duration slider")
                    .accessibilityValue("\(Int(customMinutes)) minutes")
                
                Text("120")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 4)
            
            // Quick adjust buttons
            HStack(spacing: 8) {
                QuickAdjustButton(label: "-5") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        customMinutes = max(1, customMinutes - 5)
                    }
                }
                
                QuickAdjustButton(label: "-1") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        customMinutes = max(1, customMinutes - 1)
                    }
                }
                
                Spacer()
                
                QuickAdjustButton(label: "+1") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        customMinutes = min(120, customMinutes + 1)
                    }
                }
                
                QuickAdjustButton(label: "+5") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        customMinutes = min(120, customMinutes + 5)
                    }
                }
            }
            
            // Start button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    timerManager.setCustomTime(minutes: Int(customMinutes))
                }
            }) {
                Text("Start \(Int(customMinutes)) min")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.theme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .accessibilityHint("Starts a timer for \(Int(customMinutes)) minutes")
        }
        .padding(.horizontal, 20)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
}

struct QuickAdjustButton: View {
    let label: String
    let action: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(isHovered ? Color.theme.primary : Color.theme.secondaryText)
                .frame(width: 36, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? Color.theme.primary.opacity(0.15) : Color.theme.secondaryBackground.opacity(0.5))
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    CustomTimeView()
        .environmentObject(TimerManager())
        .padding()
        .frame(width: 280)
}
