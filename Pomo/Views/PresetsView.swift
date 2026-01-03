import SwiftUI

struct PresetsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Binding var showCustomTime: Bool
    
    @AppStorage("quickStart1") private var quickStart1: Int = 25
    @AppStorage("quickStart2") private var quickStart2: Int = 5
    
    @State private var editingQuickStart1 = false
    @State private var editingQuickStart2 = false
    @State private var editText1 = ""
    @State private var editText2 = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
            
            HStack(spacing: 8) {
                QuickStartButton(
                    minutes: quickStart1,
                    isEditing: $editingQuickStart1,
                    editText: $editText1,
                    isActive: isActive(quickStart1)
                ) {
                    timerManager.setCustomTime(minutes: quickStart1)
                    showCustomTime = false
                } onSave: { newValue in
                    quickStart1 = newValue
                }
                
                QuickStartButton(
                    minutes: quickStart2,
                    isEditing: $editingQuickStart2,
                    editText: $editText2,
                    isActive: isActive(quickStart2)
                ) {
                    timerManager.setCustomTime(minutes: quickStart2)
                    showCustomTime = false
                } onSave: { newValue in
                    quickStart2 = newValue
                }
            }
            .padding(.horizontal, 16)
            
            // Custom button
            Button {
                showCustomTime.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: showCustomTime ? "xmark" : "timer")
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
            .padding(.horizontal, 16)
        }
    }
    
    private func isActive(_ minutes: Int) -> Bool {
        timerManager.state != .idle && timerManager.totalSeconds == minutes * 60
    }
}

struct QuickStartButton: View {
    let minutes: Int
    @Binding var isEditing: Bool
    @Binding var editText: String
    let isActive: Bool
    let action: () -> Void
    let onSave: (Int) -> Void
    
    @FocusState private var isFocused: Bool
    @State private var isHovering = false
    
    var body: some View {
        if isEditing {
            HStack(spacing: 4) {
                TextField("", text: $editText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .frame(width: 40)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .onSubmit {
                        saveEdit()
                    }
                    .onChange(of: editText) { _, newValue in
                        // Filter to only digits
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            editText = filtered
                        }
                    }
                
                Text("m")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.teal.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
            .onAppear {
                editText = "\(minutes)"
                isFocused = true
            }
            .onExitCommand {
                isEditing = false
            }
        } else {
            HStack(spacing: 4) {
                // Main tap area for starting timer
                Button(action: action) {
                    Text("\(minutes)m")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if isActive {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.teal)
                } else {
                    // Edit button - separate from main button
                    Button {
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                            .foregroundStyle(isHovering ? .secondary : .tertiary)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        isHovering = hovering
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.secondary.opacity(isActive ? 0.15 : 0.1), in: RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
        }
    }
    
    private func saveEdit() {
        if let value = Int(editText), value >= 1, value <= 120 {
            onSave(value)
        }
        isEditing = false
    }
}

#Preview {
    PresetsView(showCustomTime: .constant(false))
        .environmentObject(TimerManager())
        .padding()
        .frame(width: 280)
}
