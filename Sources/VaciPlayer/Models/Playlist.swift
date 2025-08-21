import Foundation

class Playlist: ObservableObject {
    @Published var songs: [Song] = []
    @Published var currentSongIndex: Int = 0
    @Published var folderPath: URL?
    @Published var pauseBetweenSongs: Double = 0.0 // in minutes
    @Published var masterVolumeMultiplier: Float = 1.0 // master volume for entire folder
    
    init() {
        loadAppState()
    }
    
    var currentSong: Song? {
        guard currentSongIndex < songs.count else { return nil }
        return songs[currentSongIndex]
    }
    
    func getEffectiveVolume(for song: Song) -> Float {
        return min(1.0, song.volume * masterVolumeMultiplier)
    }
    
    var totalDuration: TimeInterval {
        let songsDuration = songs.reduce(0) { $0 + $1.duration }
        let pausesDuration = Double(max(0, songs.count - 1)) * pauseBetweenSongs * 60 // convert minutes to seconds
        return songsDuration + pausesDuration
    }
    
    var formattedTotalDuration: String {
        let totalSeconds = Int(totalDuration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func loadSongs(from folderURL: URL) {
        // Save current folder's master volume before switching
        if folderPath != nil {
            saveMasterVolume()
        }
        
        // Stop any current playback when switching folders
        NotificationCenter.default.post(name: .folderChanged, object: nil)
        
        // Load master volume for new folder BEFORE setting folderPath
        let masterVolumeKey = "masterVolume_\(folderURL.absoluteString.hash)"
        let savedMasterVolume = UserDefaults.standard.float(forKey: masterVolumeKey)
        print("DEBUG: Loading folder \(folderURL.lastPathComponent)")
        print("DEBUG: Folder URL: \(folderURL.absoluteString)")
        print("DEBUG: Master volume key: \(masterVolumeKey)")
        print("DEBUG: Raw saved value: \(savedMasterVolume)")
        print("DEBUG: Key exists: \(UserDefaults.standard.object(forKey: masterVolumeKey) != nil)")
        
        if savedMasterVolume > 0 {
            masterVolumeMultiplier = savedMasterVolume
            print("DEBUG: Loaded master volume \(savedMasterVolume) for folder \(folderURL.lastPathComponent)")
        } else {
            // Check if key exists but value is 0 (which is valid)
            if UserDefaults.standard.object(forKey: masterVolumeKey) != nil {
                masterVolumeMultiplier = savedMasterVolume // Use 0 if explicitly saved
                print("DEBUG: Loaded master volume 0 for folder \(folderURL.lastPathComponent)")
            } else {
                masterVolumeMultiplier = 1.0 // Default for new folders
                print("DEBUG: Using default master volume 1.0 for new folder \(folderURL.lastPathComponent)")
            }
        }
        print("DEBUG: Final master volume: \(masterVolumeMultiplier)")
        
        // Force UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        folderPath = folderURL
        saveAppState()
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            let mp3Files = files.filter { $0.pathExtension.lowercased() == "mp3" }
            
            songs = mp3Files.enumerated().map { index, url in
                Song(url: url, order: index)
            }
            
            loadPersistedData()
            
            // Jump to first song when changing folders
            currentSongIndex = 0
        } catch {
            print("Error loading songs: \(error)")
        }
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        songs.move(fromOffsets: source, toOffset: destination)
        updateSongOrders()
        savePersistedData()
    }
    
    func updateSongVolume(_ song: Song, volume: Float) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].volume = volume
            savePersistedData()
        }
    }
    
    func updateSongStartTime(_ song: Song, startTime: TimeInterval) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].startTime = startTime
            savePersistedData()
        }
    }
    
    func updateSongTitle(_ song: Song, title: String) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].title = title
            savePersistedData()
        }
    }
    
    func updateSongPDFIncluded(_ song: Song, includeInPDF: Bool) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].includeInPDF = includeInPDF
            savePersistedData()
        }
    }
    
    func updateSongPDFTitle(_ song: Song, pdfTitle: String) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].pdfTitle = pdfTitle
            savePersistedData()
        }
    }
    
    func saveMasterVolume() {
        guard let folderPath = folderPath else { return }
        let key = "masterVolume_\(folderPath.absoluteString.hash)"
        UserDefaults.standard.set(masterVolumeMultiplier, forKey: key)
        print("DEBUG: Saving master volume \(masterVolumeMultiplier) for folder \(folderPath.lastPathComponent)")
        print("DEBUG: Folder URL: \(folderPath.absoluteString)")
        print("DEBUG: Save key: \(key)")
        print("DEBUG: All UserDefaults keys containing 'masterVolume': \(UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.contains("masterVolume") })")
    }
    
    func savePauseBetweenSongs() {
        UserDefaults.standard.set(pauseBetweenSongs, forKey: "pauseBetweenSongs")
    }
    
    func setCurrentSongIndex(_ index: Int) {
        currentSongIndex = index
        saveAppState()
    }
    
    private func updateSongOrders() {
        for (index, _) in songs.enumerated() {
            songs[index].order = index
        }
    }
    
    private func loadPersistedData() {
        guard let folderPath = folderPath else { return }
        let key = "playlist_\(folderPath.absoluteString.hash)"
        
        if let data = UserDefaults.standard.data(forKey: key),
           let savedSongs = try? JSONDecoder().decode([Song].self, from: data) {
            
            // Merge saved data with current songs
            for savedSong in savedSongs {
                if let index = songs.firstIndex(where: { $0.url == savedSong.url }) {
                    songs[index].volume = savedSong.volume
                    songs[index].order = savedSong.order
                    songs[index].startTime = savedSong.startTime
                    songs[index].title = savedSong.title
                    songs[index].includeInPDF = savedSong.includeInPDF
                    songs[index].pdfTitle = savedSong.pdfTitle
                }
            }
            
            // Sort by order
            songs.sort { $0.order < $1.order }
        }
        
        // Note: Master volume is now loaded in loadSongs() before this method is called
    }
    
    private func savePersistedData() {
        guard let folderPath = folderPath else { return }
        let key = "playlist_\(folderPath.absoluteString.hash)"
        
        if let data = try? JSONEncoder().encode(songs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // MARK: - App State Persistence
    
    private func saveAppState() {
        // Save last used folder
        if let folderPath = folderPath {
            UserDefaults.standard.set(folderPath.path, forKey: "lastFolderPath")
        }
        
        // Save current song index
        UserDefaults.standard.set(currentSongIndex, forKey: "currentSongIndex")
        
        // Save pause between songs setting
        UserDefaults.standard.set(pauseBetweenSongs, forKey: "pauseBetweenSongs")
        
        // Save master volume multiplier per folder
        saveMasterVolume()
    }
    
    private func loadAppState() {
        // Load pause between songs setting first (global setting)
        pauseBetweenSongs = UserDefaults.standard.double(forKey: "pauseBetweenSongs")
        
        // Load last used folder
        if let folderPathString = UserDefaults.standard.string(forKey: "lastFolderPath") {
            let folderURL = URL(fileURLWithPath: folderPathString)
            if FileManager.default.fileExists(atPath: folderURL.path) {
                loadSongs(from: folderURL)
            }
        }
        
        // Load current song index
        currentSongIndex = UserDefaults.standard.integer(forKey: "currentSongIndex")
    }
}