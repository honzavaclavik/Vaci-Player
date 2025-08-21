import Foundation
import AVFoundation

struct Song: Identifiable, Codable {
    let id: UUID
    let url: URL
    var title: String
    var volume: Float
    var order: Int
    var duration: TimeInterval
    var startTime: TimeInterval
    
    var filename: String {
        url.lastPathComponent
    }
    
    var displayTitle: String {
        title.isEmpty ? filename : title
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    init(url: URL, volume: Float = 1.0, order: Int = 0) {
        self.id = UUID()
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
        self.volume = volume
        self.order = order
        self.startTime = 0
        
        // Load duration from audio file
        let audioAsset = AVAsset(url: url)
        
        // Use the legacy API for now to avoid warnings in common MP3 files
        // The modern async API would require major architectural changes
        if audioAsset.duration.isValid && !audioAsset.duration.isIndefinite {
            self.duration = CMTimeGetSeconds(audioAsset.duration)
        } else {
            // For files where duration is not immediately available
            self.duration = 0
        }
    }
}