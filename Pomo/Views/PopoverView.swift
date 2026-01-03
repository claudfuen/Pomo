import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Timer Ring
            TimerRingView()
                .padding(.top, 20)
                .padding(.bottom, 14)
            
            // Controls
            ControlButtonsView()
                .padding(.bottom, 18)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Duration + Settings row
            BottomBarView()
                .padding(.vertical, 12)
        }
        .frame(width: 240)
        .background(.ultraThinMaterial)
        .onKeyPress(.space) {
            timerManager.toggle()
            return .handled
        }
        .focusable()
    }
}

// MARK: - Control Buttons

struct ControlButtonsView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Reset Button
            Button {
                timerManager.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(canReset ? .secondary : .quaternary)
                    .frame(width: 38, height: 38)
                    .background(.secondary.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canReset)
            
            // Play/Pause Button
            Button {
                timerManager.toggle()
            } label: {
                Image(systemName: playPauseIcon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(buttonColor, in: Circle())
            }
            .buttonStyle(.plain)
            
            // Invisible spacer to balance layout
            Color.clear
                .frame(width: 38, height: 38)
        }
    }
    
    private var canReset: Bool {
        timerManager.state != .idle
    }
    
    private var playPauseIcon: String {
        switch timerManager.state {
        case .idle, .paused, .completed:
            return "play.fill"
        case .running:
            return "pause.fill"
        }
    }
    
    private var buttonColor: Color {
        switch timerManager.state {
        case .completed:
            return .green
        case .running:
            return .teal
        default:
            return .teal
        }
    }
}

// MARK: - Bottom Bar (Duration + Settings)

struct BottomBarView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var updaterManager: UpdaterManager
    @AppStorage("selectedDuration") private var selectedDuration: Int = 25
    
    private let durations = [5, 10, 15, 20, 25, 30, 45, 60, 90]
    
    var body: some View {
        HStack(spacing: 0) {
            // Duration Picker
            Menu {
                ForEach(durations, id: \.self) { minutes in
                    Button {
                        selectDuration(minutes)
                    } label: {
                        HStack {
                            Text(formatDuration(minutes))
                            if selectedDuration == minutes {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(formatDuration(selectedDuration))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isIdle ? .primary : .tertiary)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 6))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .disabled(!isIdle)
            
            Spacer()
            
            // Keyboard hint
            Text("⌘⇧P")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.quaternary)
            
            Spacer()
            
            // Settings Menu
            Menu {
                Button {
                    updaterManager.checkForUpdates()
                } label: {
                    Label("Check for Updates", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(!updaterManager.canCheckForUpdates)
                
                Divider()
                
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("Quit Pomo", systemImage: "power")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.horizontal, 16)
    }
    
    private var isIdle: Bool {
        timerManager.state == .idle
    }
    
    private func selectDuration(_ minutes: Int) {
        selectedDuration = minutes
        timerManager.setDuration(minutes: minutes)
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins == 0 ? "\(hours)h" : "\(hours)h \(mins)m"
        }
        return "\(minutes)m"
    }
}

#Preview {
    PopoverView()
        .environmentObject(TimerManager())
        .environmentObject(UpdaterManager())
}
