import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 1.0 // This is the displayed volume (individual song volume)
    
    private var currentSongVolume: Float = 1.0
    private var masterVolumeMultiplier: Float = 1.0
    private var loadedSongURL: URL?
    
    // Loop functionality
    private var loopStart: TimeInterval?
    private var loopEnd: TimeInterval?
    private var isLooping: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFolderChanged),
            name: .folderChanged,
            object: nil
        )
    }
    
    @objc private func handleFolderChanged() {
        stop()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupAudioSession() {
        // AVAudioSession is not available on macOS
        // Audio routing is handled automatically by the system
    }
    
    func loadSong(_ song: Song, masterVolume: Float = 1.0) {
        stop()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: song.url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            loadedSongURL = song.url
            currentSongVolume = song.volume
            masterVolumeMultiplier = masterVolume
            volume = song.volume // Display the individual song volume
            
            let effectiveVolume = min(1.0, song.volume * masterVolume)
            audioPlayer?.volume = effectiveVolume
            
            duration = audioPlayer?.duration ?? 0
            
            // Set start time if specified
            if song.startTime > 0 {
                audioPlayer?.currentTime = song.startTime
                currentTime = song.startTime
            }
        } catch {
            print("Error loading song: \(error)")
        }
    }
    
    func updateMasterVolume(_ masterVolume: Float) {
        masterVolumeMultiplier = masterVolume
        let effectiveVolume = min(1.0, currentSongVolume * masterVolume)
        audioPlayer?.volume = effectiveVolume
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer = nil
        loadedSongURL = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        stopTimer()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    func setVolume(_ volume: Float) {
        currentSongVolume = volume
        self.volume = volume
        let effectiveVolume = min(1.0, volume * masterVolumeMultiplier)
        audioPlayer?.volume = effectiveVolume
    }
    
    func isSongLoaded(_ song: Song) -> Bool {
        return loadedSongURL == song.url
    }
    
    // MARK: - Loop functionality
    
    func setLoop(start: TimeInterval, end: TimeInterval) {
        loopStart = start
        loopEnd = end
        isLooping = true
    }
    
    func clearLoop() {
        loopStart = nil
        loopEnd = nil
        isLooping = false
    }
    
    func getLoopRange() -> (start: TimeInterval, end: TimeInterval)? {
        guard let start = loopStart, let end = loopEnd, isLooping else { return nil }
        return (start: start, end: end)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.currentTime = self.audioPlayer?.currentTime ?? 0
            
            // Check for loop
            if self.isLooping,
               let loopEnd = self.loopEnd,
               let loopStart = self.loopStart,
               self.currentTime >= loopEnd {
                self.audioPlayer?.currentTime = loopStart
                self.currentTime = loopStart
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
}