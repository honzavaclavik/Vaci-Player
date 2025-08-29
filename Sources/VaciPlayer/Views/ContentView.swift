import SwiftUI

struct ContentView: View {
    @StateObject private var playlist = Playlist()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var folderManager = FolderManager()
    @State private var showingFolderPicker = false
    @State private var isEditingMode = false
    
    // Initialize audioInputManager with audioManager dependency
    @State private var audioInputManager: AudioInputManager?
    
    var body: some View {
        NavigationSplitView {
            if let inputManager = audioInputManager {
                SidebarView(
                    playlist: playlist, 
                    folderManager: folderManager,
                    audioManager: audioManager,
                    audioInputManager: inputManager,
                    showingFolderPicker: $showingFolderPicker
                )
            }
        } detail: {
            if let inputManager = audioInputManager {
                MainPlayerView(playlist: playlist, audioManager: audioManager, audioInputManager: inputManager, isEditingMode: $isEditingMode)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 0))
        .onReceive(NotificationCenter.default.publisher(for: .openFolderFromMenu)) { notification in
            if let url = notification.object as? URL {
                playlist.loadSongs(from: url)
                folderManager.addFavoriteFolder(url)
                audioManager.playbackRate = playlist.playbackRate
                audioManager.pitch = playlist.pitch
            }
        }
        .onReceive(playlist.$playbackRate) { rate in
            audioManager.playbackRate = rate
        }
        .onReceive(playlist.$pitch) { pitchValue in
            audioManager.pitch = pitchValue
        }
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    playlist.loadSongs(from: url)
                    folderManager.addFavoriteFolder(url)
                    audioManager.playbackRate = playlist.playbackRate
                    audioManager.pitch = playlist.pitch
                }
            case .failure(let error):
                print("Error selecting folder: \(error)")
            }
        }
        .onKeyPress(.space) {
            guard !isEditingMode else { return .ignored }
            handleSpaceKey()
            return .handled
        }
        .onKeyPress(.return) {
            guard !isEditingMode else { return .ignored }
            handleEnterKey()
            return .handled
        }
        .onKeyPress(.upArrow) {
            guard !isEditingMode else { return .ignored }
            handlePreviousSong()
            return .handled
        }
        .onKeyPress(.downArrow) {
            guard !isEditingMode else { return .ignored }
            handleNextSong()
            return .handled
        }
        .onKeyPress(.escape) {
            guard !isEditingMode else { return .ignored }
            handleEscapeKey()
            return .handled
        }
        .onKeyPress("0") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(0)
            return .handled
        }
        .onKeyPress("1") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(1)
            return .handled
        }
        .onKeyPress("2") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(2)
            return .handled
        }
        .onKeyPress("3") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(3)
            return .handled
        }
        .onKeyPress("4") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(4)
            return .handled
        }
        .onKeyPress("5") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(5)
            return .handled
        }
        .onKeyPress("6") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(6)
            return .handled
        }
        .onKeyPress("7") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(7)
            return .handled
        }
        .onKeyPress("8") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(8)
            return .handled
        }
        .onKeyPress("9") {
            guard !isEditingMode else { return .ignored }
            handleNumberKey(9)
            return .handled
        }
        .onKeyPress("+") {
            guard !isEditingMode else { return .ignored }
            audioManager.increasePlaybackRate()
            playlist.playbackRate = audioManager.playbackRate
            playlist.savePlaybackRate()
            return .handled
        }
        .onKeyPress("-") {
            guard !isEditingMode else { return .ignored }
            audioManager.decreasePlaybackRate()
            playlist.playbackRate = audioManager.playbackRate
            playlist.savePlaybackRate()
            return .handled
        }
        .onKeyPress("=") {
            guard !isEditingMode else { return .ignored }
            audioManager.resetPlaybackRate()
            playlist.playbackRate = audioManager.playbackRate
            playlist.savePlaybackRate()
            return .handled
        }
        .onKeyPress("[") {
            guard !isEditingMode else { return .ignored }
            audioManager.decreasePitch()
            playlist.pitch = audioManager.pitch
            playlist.savePitch()
            return .handled
        }
        .onKeyPress("]") {
            guard !isEditingMode else { return .ignored }
            audioManager.increasePitch()
            playlist.pitch = audioManager.pitch
            playlist.savePitch()
            return .handled
        }
        .onKeyPress("\\") {
            guard !isEditingMode else { return .ignored }
            audioManager.resetPitch()
            playlist.pitch = audioManager.pitch
            playlist.savePitch()
            return .handled
        }
        .onKeyPress("i") {
            guard !isEditingMode else { return .ignored }
            audioInputManager?.togglePanelVisibility()
            return .handled
        }
        .onAppear {
            if audioInputManager == nil {
                audioInputManager = AudioInputManager(audioManager: audioManager)
            }
        }
    }
    
    private func handleSpaceKey() {
        if playlist.songs.isEmpty {
            return // No songs to play
        }
        
        if audioManager.isPlaying {
            // If playing, pause
            audioManager.pause()
        } else {
            // If not playing, start playing current song or first song
            if playlist.currentSong == nil && !playlist.songs.isEmpty {
                playlist.setCurrentSongIndex(0)
            }
            
            if let currentSong = playlist.currentSong {
                // Load song only if it's not the currently loaded song
                if !audioManager.isSongLoaded(currentSong) {
                    audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier, playbackRate: audioManager.playbackRate, pitch: audioManager.pitch)
                }
                audioManager.play()
            }
        }
    }
    
    private func handleEnterKey() {
        guard let currentSong = playlist.currentSong else { return }
        
        // Restart current song from configured start time
        audioManager.seek(to: currentSong.startTime)
        if !audioManager.isPlaying {
            audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier, playbackRate: audioManager.playbackRate, pitch: audioManager.pitch)
            audioManager.play()
        }
    }
    
    private func handlePreviousSong() {
        guard !playlist.songs.isEmpty else { return }
        
        // Pause playback when changing songs
        if audioManager.isPlaying {
            audioManager.pause()
        }
        
        if playlist.currentSongIndex > 0 {
            playlist.setCurrentSongIndex(playlist.currentSongIndex - 1)
        } else {
            // Loop to last song
            playlist.setCurrentSongIndex(playlist.songs.count - 1)
        }
        
        // Load new song and reset to beginning
        if let currentSong = playlist.currentSong {
            audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier, playbackRate: audioManager.playbackRate)
        }
    }
    
    private func handleNextSong() {
        guard !playlist.songs.isEmpty else { return }
        
        // Pause playback when changing songs
        if audioManager.isPlaying {
            audioManager.pause()
        }
        
        if playlist.currentSongIndex < playlist.songs.count - 1 {
            playlist.setCurrentSongIndex(playlist.currentSongIndex + 1)
        } else {
            // Loop to first song
            playlist.setCurrentSongIndex(0)
        }
        
        // Load new song and reset to beginning
        if let currentSong = playlist.currentSong {
            audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier, playbackRate: audioManager.playbackRate)
        }
    }
    
    private func handleEscapeKey() {
        if audioManager.isPlaying {
            audioManager.pause()
        }
    }
    
    private func handleNumberKey(_ number: Int) {
        guard playlist.currentSong != nil, audioManager.duration > 0 else { return }
        
        let percentage = Double(number) / 10.0
        let seekTime = audioManager.duration * percentage
        audioManager.seek(to: seekTime)
    }
}