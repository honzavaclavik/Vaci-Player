import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 1.0 // This is the displayed volume (individual song volume)
    @Published var playbackRate: Float = 1.0 // Playback speed (0.5x to 2.0x)
    @Published var pitch: Float = 0.0 // Pitch in semitones (-12 to +12)
    
    private var currentSongVolume: Float = 1.0
    private var masterVolumeMultiplier: Float = 1.0
    private var loadedSongURL: URL?
    
    // AVAudioEngine components
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var timePitchEffect = AVAudioUnitTimePitch()
    private var audioFile: AVAudioFile?
    
    // Loop functionality
    private var loopStart: TimeInterval?
    private var loopEnd: TimeInterval?
    private var isLooping: Bool = false
    
    private var timer: Timer?
    private var startTime: TimeInterval = 0
    
    override init() {
        super.init()
        setupAudioEngine()
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
    
    private func setupAudioEngine() {
        // Set up the audio engine chain
        audioEngine.attach(playerNode)
        audioEngine.attach(timePitchEffect)
        
        // Connect nodes: playerNode -> timePitchEffect -> mainMixerNode
        audioEngine.connect(playerNode, to: timePitchEffect, format: nil)
        audioEngine.connect(timePitchEffect, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func loadSong(_ song: Song, masterVolume: Float = 1.0, playbackRate: Float = 1.0, pitch: Float = 0.0) {
        stop()
        
        do {
            audioFile = try AVAudioFile(forReading: song.url)
            
            loadedSongURL = song.url
            currentSongVolume = song.volume
            masterVolumeMultiplier = masterVolume
            volume = song.volume // Display the individual song volume
            self.playbackRate = playbackRate
            self.pitch = pitch
            startTime = song.startTime
            
            // Set volume
            let effectiveVolume = min(1.0, song.volume * masterVolume)
            playerNode.volume = effectiveVolume
            
            // Configure time pitch effect
            timePitchEffect.rate = playbackRate
            timePitchEffect.pitch = pitch * 100 // Convert semitones to cents (1 semitone = 100 cents)
            
            // Get duration from audio file
            if let audioFile = audioFile {
                let sampleRate = audioFile.processingFormat.sampleRate
                let frameCount = audioFile.length
                duration = Double(frameCount) / sampleRate
            } else {
                duration = 0
            }
            
            currentTime = startTime
        } catch {
            print("Error loading song: \(error)")
        }
    }
    
    func updateMasterVolume(_ masterVolume: Float) {
        masterVolumeMultiplier = masterVolume
        let effectiveVolume = min(1.0, currentSongVolume * masterVolume)
        playerNode.volume = effectiveVolume
    }
    
    func play() {
        guard let audioFile = audioFile else { return }
        
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                print("Error starting audio engine: \(error)")
                return
            }
        }
        
        // Calculate start frame based on start time
        let sampleRate = audioFile.processingFormat.sampleRate
        let startFrame = AVAudioFramePosition(startTime * sampleRate)
        let frameCount = audioFile.length - startFrame
        
        guard frameCount > 0 else { return }
        
        // Schedule the audio file to play from the start time
        playerNode.scheduleSegment(audioFile, 
                                   startingFrame: startFrame, 
                                   frameCount: AVAudioFrameCount(frameCount), 
                                   at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.stopTimer()
            }
        }
        
        playerNode.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        playerNode.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        playerNode.stop()
        audioFile = nil
        loadedSongURL = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        stopTimer()
    }
    
    func seek(to time: TimeInterval) {
        guard let audioFile = audioFile else { return }
        
        let wasPlaying = isPlaying
        playerNode.stop()
        
        startTime = time
        currentTime = time
        
        if wasPlaying {
            play()
        }
    }
    
    func setVolume(_ volume: Float) {
        currentSongVolume = volume
        self.volume = volume
        let effectiveVolume = min(1.0, volume * masterVolumeMultiplier)
        playerNode.volume = effectiveVolume
    }
    
    func setPlaybackRate(_ rate: Float) {
        let clampedRate = max(0.5, min(2.0, rate))
        playbackRate = clampedRate
        timePitchEffect.rate = clampedRate
    }
    
    func increasePlaybackRate() {
        let newRate = min(2.0, playbackRate + 0.1)
        setPlaybackRate(newRate)
    }
    
    func decreasePlaybackRate() {
        let newRate = max(0.5, playbackRate - 0.1)
        setPlaybackRate(newRate)
    }
    
    func resetPlaybackRate() {
        setPlaybackRate(1.0)
    }
    
    func setPitch(_ pitchInSemitones: Float) {
        let clampedPitch = max(-12.0, min(12.0, pitchInSemitones))
        pitch = clampedPitch
        timePitchEffect.pitch = clampedPitch * 100 // Convert semitones to cents
    }
    
    func increasePitch() {
        let newPitch = min(12.0, pitch + 0.5)
        setPitch(newPitch)
    }
    
    func decreasePitch() {
        let newPitch = max(-12.0, pitch - 0.5)
        setPitch(newPitch)
    }
    
    func resetPitch() {
        setPitch(0.0)
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
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let audioFile = self.audioFile else { return }
            
            // Calculate current time based on player node position
            if let nodeTime = self.playerNode.lastRenderTime,
               let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) {
                let sampleRate = audioFile.processingFormat.sampleRate
                let elapsedTime = Double(playerTime.sampleTime) / sampleRate / Double(self.playbackRate)
                self.currentTime = self.startTime + elapsedTime
            }
            
            // Check for loop
            if self.isLooping,
               let loopEnd = self.loopEnd,
               let loopStart = self.loopStart,
               self.currentTime >= loopEnd {
                self.seek(to: loopStart)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

