import SwiftUI

struct CustomTimeView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Binding var isVisible: Bool
    // Keep as Double for backwards compatibility with existing user preferences
    @AppStorage("customMinutes") private var customMinutes: Double = 25
    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Time input
            HStack(alignment: .center, spacing: 8) {
                TextField("", text: $inputText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.theme.primary)
                    .frame(width: 70)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .onSubmit {
                        startTimer()
                    }
                    .onChange(of: inputText) { _, newValue in
                        // Filter to only digits
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            inputText = filtered
                        }
                    }
                
                Text("min")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.theme.secondaryText)
            }
            .padding(.vertical, 8)
            .accessibilityLabel("\(displayMinutes) minutes")
            
            // Start button
            Button(action: startTimer) {
                Text("Start \(displayMinutes) min")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.theme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(displayMinutes < 1 || displayMinutes > 120)
            .accessibilityHint("Starts a timer for \(displayMinutes) minutes")
        }
        .padding(.horizontal, 20)
        .onAppear {
            inputText = "\(Int(customMinutes))"
            isFocused = true
        }
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
    
    private var displayMinutes: Int {
        Int(inputText) ?? Int(customMinutes)
    }
    
    private func startTimer() {
        if let value = Int(inputText), value >= 1, value <= 120 {
            customMinutes = Double(value)
            timerManager.setCustomTime(minutes: value)
            isVisible = false
        }
    }
}

#Preview {
    CustomTimeView(isVisible: .constant(true))
        .environmentObject(TimerManager())
        .padding()
        .frame(width: 280)
}
