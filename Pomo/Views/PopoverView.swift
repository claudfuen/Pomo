import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Timer Display
            TimerRingView()
                .padding(.top, 20)
                .padding(.bottom, 12)
            
            // Control Buttons
            ControlButtonsView()
                .padding(.bottom, 16)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Duration Picker
            DurationPickerView()
                .padding(.vertical, 14)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Footer
            FooterView()
                .padding(.vertical, 10)
        }
        .frame(width: 260)
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
        HStack(spacing: 20) {
            // Reset Button
            Button {
                timerManager.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(canReset ? .primary : .quaternary)
                    .frame(width: 40, height: 40)
                    .background(.secondary.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canReset)
            .keyboardShortcut("r", modifiers: .command)
            
            // Play/Pause Button
            Button {
                timerManager.toggle()
            } label: {
                Image(systemName: playPauseIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(buttonColor, in: Circle())
            }
            .buttonStyle(.plain)
            
            // +1 Minute Button (only when running or paused)
            Button {
                timerManager.addMinute()
            } label: {
                Text("+1m")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(canAddTime ? .primary : .quaternary)
                    .frame(width: 40, height: 40)
                    .background(.secondary.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canAddTime)
        }
    }
    
    private var canReset: Bool {
        timerManager.state != .idle
    }
    
    private var canAddTime: Bool {
        timerManager.state == .running || timerManager.state == .paused
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
            return .orange
        default:
            return .teal
        }
    }
}

// MARK: - Duration Picker

struct DurationPickerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @AppStorage("selectedDuration") private var selectedDuration: Int = 25
    
    private let durations = [5, 10, 15, 20, 25, 30, 45, 60]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Duration")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Spacer()
                
                if timerManager.state != .idle {
                    Text("Reset to change")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 20)
            
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
                
                Divider()
                
                Menu("More...") {
                    ForEach([1, 2, 3, 90, 120], id: \.self) { minutes in
                        Button {
                            selectDuration(minutes)
                        } label: {
                            Text(formatDuration(minutes))
                        }
                    }
                }
            } label: {
                HStack {
                    Text(formatDuration(selectedDuration))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(timerManager.state == .idle ? .primary : .secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            }
            .menuStyle(.borderlessButton)
            .disabled(timerManager.state != .idle)
            .padding(.horizontal, 16)
        }
    }
    
    private func selectDuration(_ minutes: Int) {
        selectedDuration = minutes
        timerManager.setDuration(minutes: minutes)
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours) hour\(hours > 1 ? "s" : "")"
            }
            return "\(hours)h \(mins)m"
        }
        return "\(minutes) min"
    }
}

// MARK: - Footer

struct FooterView: View {
    @EnvironmentObject var updaterManager: UpdaterManager
    
    var body: some View {
        HStack {
            Text("⌘⇧P")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
            
            Spacer()
            
            Button("Updates") {
                updaterManager.checkForUpdates()
            }
            .buttonStyle(.plain)
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
            .disabled(!updaterManager.canCheckForUpdates)
            
            Text("·")
                .foregroundStyle(.quaternary)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    PopoverView()
        .environmentObject(TimerManager())
        .environmentObject(UpdaterManager())
}
