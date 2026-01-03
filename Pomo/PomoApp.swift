import SwiftUI
import AppKit

// Global reference that persists across all instances
private struct AppState {
    static weak var timerManager: TimerManager?
}

@main
struct PomoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var timerManager: TimerManager
    @StateObject private var updaterManager: UpdaterManager
    
    init() {
        let timer = TimerManager()
        _timerManager = StateObject(wrappedValue: timer)
        _updaterManager = StateObject(wrappedValue: UpdaterManager())
        
        // Store in global state immediately
        AppState.timerManager = timer
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

class AppDelegate: NSObject, NSApplicationDelegate {
    
    override init() {
        super.init()
        print("[Pomo] AppDelegate init")
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("[Pomo] applicationWillFinishLaunching")
        
        // Register for Apple Events
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("[Pomo] applicationDidFinishLaunching")
    }
    
    // Support standard open urls
    func application(_ application: NSApplication, open urls: [URL]) {
        print("[Pomo] application open urls: \(urls)")
        if let url = urls.first {
            handleURL(url)
        }
    }
    
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        print("[Pomo] handleURLEvent called")
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            print("[Pomo] Failed to parse URL from Apple Event")
            return
        }
        handleURL(url)
    }
    
    private func handleURL(_ url: URL) {
        print("[Pomo] Processing URL: \(url.absoluteString)")
        
        // Use the global state which is guaranteed to be set by App init
        guard let timerManager = AppState.timerManager else {
            print("[Pomo] Error: AppState.timerManager is nil")
            return
        }
        
        guard url.scheme == "pomo" else { return }
        
        let command = url.host ?? ""
        let parameter = url.pathComponents.count > 1 ? url.pathComponents[1] : nil
        
        Task { @MainActor in
            print("[Pomo] Executing command: \(command) with param: \(parameter ?? "none")")
            
            switch command {
            case "start":
                if let param = parameter, let minutes = Int(param), minutes > 0 {
                    timerManager.setCustomTime(minutes: minutes)
                } else {
                    timerManager.start()
                }
            case "toggle":
                timerManager.toggle()
            case "pause":
                timerManager.pause()
            case "resume":
                timerManager.resume()
            case "reset":
                timerManager.reset()
            default:
                break
            }
        }
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
