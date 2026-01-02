import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var showCustomTime = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Timer Display
            TimerRingView()
                .padding(.top, 24)
                .padding(.bottom, 16)
            
            // Session Counter
            SessionCounterView()
                .padding(.bottom, 20)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Presets
            PresetsView(showCustomTime: $showCustomTime)
                .padding(.vertical, 16)
            
            // Custom Time Input
            if showCustomTime {
                CustomTimeView()
                    .padding(.bottom, 16)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Footer
            FooterView()
                .padding(.vertical, 12)
        }
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .onKeyPress(.space) {
            timerManager.toggle()
            return .handled
        }
        .focusable()
    }
}

struct FooterView: View {
    var body: some View {
        HStack {
            Text("⌘⇧P to toggle")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)
            .onHover { isHovered in
                if isHovered {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    PopoverView()
        .environmentObject(TimerManager())
}
