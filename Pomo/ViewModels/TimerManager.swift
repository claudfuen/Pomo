import SwiftUI
import Combine
import UserNotifications
import HotKey

@MainActor
class TimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var state: TimerState = .idle
    @Published var totalSeconds: Int = 1500
    @Published var remainingSeconds: Int = 1500
    
    // MARK: - Persisted Properties
    @AppStorage("lastUsedMinutes") private var lastUsedMinutes: Int = 25
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var soundManager = SoundManager()
    private var hotKey: HotKey?
    
    // MARK: - Computed Properties
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }
    
    var remainingProgress: Double {
        guard totalSeconds > 0 else { return 1 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }
    
    var displayTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var menuBarText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        if minutes > 0 {
            return seconds > 0 ? String(format: "%d:%02d", minutes, seconds) : "\(minutes)m"
        }
        return "\(seconds)s"
    }
    
    var menuBarIcon: String {
        switch state {
        case .idle:
            return "timer"
        case .running:
            return "timer"
        case .paused:
            return "pause.circle.fill"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
    
    var progressColor: Color {
        let remaining = remainingProgress
        if remaining > 0.4 {
            return Color.theme.timerActive
        } else if remaining > 0.2 {
            return Color.theme.timerWarning
        } else {
            return Color.theme.timerUrgent
        }
    }
    
    // MARK: - Initialization
    init() {
        requestNotificationPermission()
        setupHotKey()
    }
    
    private func setupHotKey() {
        hotKey = HotKey(key: .p, modifiers: [.command, .shift])
        hotKey?.keyDownHandler = { [weak self] in
            Task { @MainActor in
                self?.toggle()
            }
        }
    }
    
    // MARK: - Timer Control
    func start(minutes: Int? = nil) {
        if let minutes = minutes {
            totalSeconds = minutes * 60
            remainingSeconds = totalSeconds
            lastUsedMinutes = minutes
        } else if state == .idle {
            totalSeconds = lastUsedMinutes * 60
            remainingSeconds = totalSeconds
        }
        
        state = .running
        startTimer()
    }
    
    func pause() {
        state = .paused
        timer?.cancel()
        timer = nil
    }
    
    func resume() {
        state = .running
        startTimer()
    }
    
    func reset() {
        timer?.cancel()
        timer = nil
        state = .idle
        remainingSeconds = totalSeconds
    }
    
    func toggle() {
        switch state {
        case .idle:
            start()
        case .running:
            pause()
        case .paused:
            resume()
        case .completed:
            reset()
        }
    }
    
    func setCustomTime(minutes: Int) {
        reset()
        start(minutes: minutes)
    }
    
    // MARK: - Private Methods
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            complete()
            return
        }
        remainingSeconds -= 1
        
        if remainingSeconds == 0 {
            complete()
        }
    }
    
    private func complete() {
        timer?.cancel()
        timer = nil
        state = .completed
        
        soundManager.playCompletionSound()
        sendCompletionNotification()
    }
    
    // MARK: - Notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time's Up!"
        content.body = "Great work! Take a break."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
