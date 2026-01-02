import SwiftUI

struct PresetsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Binding var showCustomTime: Bool
    
    private let presets = TimerPreset.defaults
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section label
            Text("Quick Start")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 20)
            
            // Preset buttons
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(presets) { preset in
                    PresetButton(
                        preset: preset,
                        isActive: isPresetActive(preset)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            timerManager.setPreset(preset)
                            showCustomTime = false
                        }
                    }
                }
                
                // Custom button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showCustomTime.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: showCustomTime ? "xmark" : "slider.horizontal.3")
                            .font(.system(size: 12, weight: .medium))
                        Text("Custom")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(showCustomTime ? Color.theme.primary : Color.theme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(showCustomTime ? Color.theme.primary.opacity(0.15) : Color.theme.secondaryBackground.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(showCustomTime ? Color.theme.primary.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Custom duration")
                .accessibilityHint(showCustomTime ? "Closes custom time picker" : "Opens custom time picker")
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func isPresetActive(_ preset: TimerPreset) -> Bool {
        timerManager.state != .idle && 
        timerManager.totalSeconds == preset.seconds
    }
}

struct PresetButton: View {
    let preset: TimerPreset
    let isActive: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    private var categoryColor: Color {
        switch preset.category {
        case .focus:
            return Color.theme.focusPreset
        case .shortBreak, .longBreak:
            return Color.theme.breakPreset
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Category indicator
                Circle()
                    .fill(categoryColor)
                    .frame(width: 6, height: 6)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(preset.minutes)m")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.theme.text)
                    
                    Text(preset.name)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.theme.tertiaryText)
                }
                
                Spacer()
                
                // Active indicator
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(categoryColor)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? categoryColor.opacity(0.15) : (isHovered ? categoryColor.opacity(0.1) : Color.theme.secondaryBackground.opacity(0.5)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isActive ? categoryColor.opacity(0.5) : (isHovered ? categoryColor.opacity(0.3) : Color.clear), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .accessibilityLabel("\(preset.name), \(preset.minutes) minutes")
        .accessibilityHint(isActive ? "Currently active" : "Double tap to start")
    }
}

#Preview {
    PresetsView(showCustomTime: .constant(false))
        .environmentObject(TimerManager())
        .padding()
        .frame(width: 280)
}
