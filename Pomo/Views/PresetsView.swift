import SwiftUI

struct PresetsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Binding var showCustomTime: Bool
    
    private let presets = TimerPreset.defaults
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(presets) { preset in
                    PresetButton(
                        preset: preset,
                        isActive: isPresetActive(preset)
                    ) {
                        timerManager.setPreset(preset)
                        showCustomTime = false
                    }
                }
                
                // Custom button
                Button {
                    showCustomTime.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: showCustomTime ? "xmark" : "slider.horizontal.3")
                            .font(.system(size: 12))
                        Text("Custom")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(showCustomTime ? .teal : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func isPresetActive(_ preset: TimerPreset) -> Bool {
        timerManager.state != .idle && timerManager.totalSeconds == preset.seconds
    }
}

struct PresetButton: View {
    let preset: TimerPreset
    let isActive: Bool
    let action: () -> Void
    
    private var accentColor: Color {
        preset.category == .focus ? .teal : .purple
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 6, height: 6)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(preset.minutes)m")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.primary)
                    
                    Text(preset.name)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                if isActive {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(.secondary.opacity(isActive ? 0.15 : 0.1), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PresetsView(showCustomTime: .constant(false))
        .environmentObject(TimerManager())
        .padding()
        .frame(width: 280)
}
