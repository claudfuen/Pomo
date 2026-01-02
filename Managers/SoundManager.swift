import AppKit
import AVFoundation

class SoundManager {
    private var audioPlayer: AVAudioPlayer?
    
    func playCompletionSound() {
        // Use system sound for native feel
        NSSound(named: "Glass")?.play()
    }
    
    func playTickSound() {
        NSSound(named: "Tink")?.play()
    }
}

