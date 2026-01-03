import Foundation
import Sparkle

/// Manages app updates using Sparkle framework
final class UpdaterManager: ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    
    init() {
        // Initialize Sparkle updater controller
        // startingUpdater: true starts automatic update checks on launch
        // Delegates are nil for default behavior
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        
        // Observe whether we can check for updates
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
    
    /// Manually trigger an update check
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}


