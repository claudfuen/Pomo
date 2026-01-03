import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Timer Display
            TimerRingView()
                .padding(.top, 24)
                .padding(.bottom, 16)
            
            // Control Buttons
            ControlButtonsView()
                .padding(.bottom, 20)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Duration Picker
            DurationPickerView()
                .padding(.vertical, 16)
            
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

// MARK: - Control Buttons

struct ControlButtonsView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Reset Button
            Button {
                timerManager.reset()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(timerManager.state == .idle ? .tertiary : .secondary)
                    .frame(width: 44, height: 44)
                    .background(.secondary.opacity(0.1), in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(timerManager.state == .idle)
            .help("Reset timer")
            
            // Play/Pause Button
            Button {
                timerManager.toggle()
            } label: {
                Image(systemName: playPauseIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.teal, in: Circle())
            }
            .buttonStyle(.plain)
            .help(playPauseHelp)
            
            // Spacer to balance the layout (same size as reset button)
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    private var playPauseIcon: String {
        switch timerManager.state {
        case .idle, .paused, .completed:
            return "play.fill"
        case .running:
            return "pause.fill"
        }
    }
    
    private var playPauseHelp: String {
        switch timerManager.state {
        case .idle:
            return "Start timer"
        case .running:
            return "Pause timer"
        case .paused:
            return "Resume timer"
        case .completed:
            return "Start new timer"
        }
    }
}

// MARK: - Duration Picker

struct DurationPickerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @AppStorage("selectedDuration") private var selectedDuration: Int = 25
    
    private let durations = [5, 10, 15, 20, 25, 30, 45, 60, 90]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
            
            Menu {
                ForEach(durations, id: \.self) { minutes in
                    Button {
                        selectedDuration = minutes
                        timerManager.setCustomTime(minutes: minutes)
                    } label: {
                        HStack {
                            Text(formatDuration(minutes))
                            if isCurrentDuration(minutes) {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                Divider()
                
                // Custom option
                Menu("Custom...") {
                    ForEach([1, 2, 3, 35, 40, 50, 75, 120], id: \.self) { minutes in
                        Button {
                            selectedDuration = minutes
                            timerManager.setCustomTime(minutes: minutes)
                        } label: {
                            Text(formatDuration(minutes))
                        }
                    }
                }
            } label: {
                HStack {
                    Text(formatDuration(currentMinutes))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .frame(height: 40)
                .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            .menuStyle(.borderlessButton)
            .padding(.horizontal, 16)
        }
    }
    
    private var currentMinutes: Int {
        timerManager.totalSeconds / 60
    }
    
    private func isCurrentDuration(_ minutes: Int) -> Bool {
        currentMinutes == minutes
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
            Text("⌘⇧P to toggle")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button("Updates") {
                updaterManager.checkForUpdates()
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)
            .disabled(!updaterManager.canCheckForUpdates)
            .onHover { isHovered in
                if isHovered && updaterManager.canCheckForUpdates {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            
            Text("•")
                .font(.caption)
                .foregroundStyle(.tertiary)
            
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
        .environmentObject(UpdaterManager())
}
