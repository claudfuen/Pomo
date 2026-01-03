import Foundation
import AppKit

/// Handles URL scheme commands for external control (e.g., from Raycast)
/// Supported URLs:
/// - pomo://start/5          (5 min)
/// - pomo://start/10         (10 min)
/// - pomo://start/15         (15 min)
/// - pomo://start/25         (25 min)
/// - pomo://start/45         (45 min)
/// - pomo://start/<minutes>  (any custom duration)
/// - pomo://toggle
/// - pomo://pause
/// - pomo://resume
/// - pomo://reset
class URLSchemeHandler: ObservableObject {
    private weak var timerManager: TimerManager?
    
    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        registerURLHandler()
    }
    
    private func registerURLHandler() {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    @objc private func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }
        
        // Dispatch to main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            self?.handleURL(url)
        }
    }
    
    private func handleURL(_ url: URL) {
        guard url.scheme == "pomo" else { return }
        
        let command = url.host ?? ""
        let parameter = url.pathComponents.count > 1 ? url.pathComponents[1] : nil
        
        switch command {
        case "start":
            handleStart(parameter: parameter)
        case "toggle":
            timerManager?.toggle()
        case "pause":
            timerManager?.pause()
        case "resume":
            timerManager?.resume()
        case "reset":
            timerManager?.reset()
        default:
            break
        }
    }
    
    private func handleStart(parameter: String?) {
        guard let timerManager = timerManager else { return }
        
        // Try to parse as a number first (e.g., "5", "10", "25")
        if let param = parameter, let minutes = Int(param), minutes > 0 {
            timerManager.setCustomTime(minutes: minutes)
            return
        }
        
        // Fall back to named presets for backwards compatibility
        switch parameter?.lowercased() {
        case "focus":
            timerManager.setCustomTime(minutes: 25)
        case "deep-work", "deepwork":
            timerManager.setCustomTime(minutes: 45)
        case "short-break", "shortbreak":
            timerManager.setCustomTime(minutes: 5)
        case "long-break", "longbreak":
            timerManager.setCustomTime(minutes: 15)
        default:
            // Start with last used duration
            timerManager.start()
        }
    }
}
