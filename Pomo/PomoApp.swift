import SwiftUI

@main
struct PomoApp: App {
    @StateObject private var timerManager: TimerManager
    @StateObject private var updaterManager: UpdaterManager
    @StateObject private var urlSchemeHandler: URLSchemeHandler
    
    init() {
        // Create shared TimerManager instance
        let timer = TimerManager()
        
        // Initialize all StateObjects with the shared timer
        _timerManager = StateObject(wrappedValue: timer)
        _updaterManager = StateObject(wrappedValue: UpdaterManager())
        _urlSchemeHandler = StateObject(wrappedValue: URLSchemeHandler(timerManager: timer))
    }
    
    var body: some Scene {
        MenuBarExtra {
            PopoverView()
                .environmentObject(timerManager)
                .environmentObject(updaterManager)
        } label: {
            MenuBarLabel()
                .environmentObject(timerManager)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: timerManager.menuBarIcon)
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.pulse, options: .repeating, isActive: timerManager.state == .completed)
            
            if timerManager.state == .running || timerManager.state == .paused {
                Text(timerManager.menuBarText)
                    .font(.system(.body, design: .monospaced))
                    .monospacedDigit()
            }
        }
    }
}
