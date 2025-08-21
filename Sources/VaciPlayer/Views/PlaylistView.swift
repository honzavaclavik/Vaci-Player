import SwiftUI

struct PlaylistView: View {
    @ObservedObject var playlist: Playlist
    @ObservedObject var audioManager: AudioManager
    @Binding var isEditingMode: Bool
    
    var body: some View {
        List {
            ForEach(Array(playlist.songs.enumerated()), id: \.element.id) { index, song in
                SongRowView(
                    song: song,
                    isCurrentSong: index == playlist.currentSongIndex,
                    onPlay: {
                        // Pause playback when selecting song (like arrow keys)
                        if audioManager.isPlaying {
                            audioManager.pause()
                        }
                        
                        playlist.setCurrentSongIndex(index)
                        
                        // Load song and reset to beginning
                        audioManager.loadSong(song, masterVolume: playlist.masterVolumeMultiplier)
                    },
                    onVolumeChange: { volume in
                        playlist.updateSongVolume(song, volume: volume)
                        if index == playlist.currentSongIndex {
                            audioManager.setVolume(volume)
                        }
                    },
                    onStartTimeChange: { startTime in
                        playlist.updateSongStartTime(song, startTime: startTime)
                    },
                    onTitleChange: { title in
                        playlist.updateSongTitle(song, title: title)
                    },
                    isEditingMode: $isEditingMode
                )
            }
            .onMove(perform: playlist.moveSong)
        }
        .listStyle(.inset)
    }
}

struct SongRowView: View {
    let song: Song
    let isCurrentSong: Bool
    let onPlay: () -> Void
    let onVolumeChange: (Float) -> Void
    let onStartTimeChange: (TimeInterval) -> Void
    let onTitleChange: (String) -> Void
    @Binding var isEditingMode: Bool
    
    @State private var volume: Float
    @State private var startTime: TimeInterval
    @State private var showingStartTimeField: Bool = false
    @State private var showingRenameField: Bool = false
    @State private var editingTitle: String = ""
    @State private var isHovering: Bool = false
    
    init(song: Song, isCurrentSong: Bool, onPlay: @escaping () -> Void, onVolumeChange: @escaping (Float) -> Void, onStartTimeChange: @escaping (TimeInterval) -> Void, onTitleChange: @escaping (String) -> Void, isEditingMode: Binding<Bool>) {
        self.song = song
        self.isCurrentSong = isCurrentSong
        self.onPlay = onPlay
        self.onVolumeChange = onVolumeChange
        self.onStartTimeChange = onStartTimeChange
        self.onTitleChange = onTitleChange
        self._isEditingMode = isEditingMode
        self._volume = State(initialValue: song.volume)
        self._startTime = State(initialValue: song.startTime)
        self._editingTitle = State(initialValue: song.title)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Play button
            Button(action: onPlay) {
                Image(systemName: isCurrentSong ? "speaker.wave.2.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isCurrentSong ? .blue : .primary)
            }
            .buttonStyle(.plain)
            
            // Song info
            VStack(alignment: .leading, spacing: 4) {
                Button(action: { 
                    editingTitle = song.title
                    showingRenameField.toggle() 
                }) {
                    HStack(spacing: 4) {
                        Text(song.displayTitle)
                            .fontWeight(isCurrentSong ? .semibold : .regular)
                            .foregroundStyle(isCurrentSong ? .blue : .primary)
                            .lineLimit(1)
                        
                        if isHovering {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingRenameField) {
                    VStack(spacing: 12) {
                        Text("Přejmenovat písničku")
                            .font(.headline)
                        
                        TextField("Název písničky", text: $editingTitle)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 250)
                            .onAppear {
                                isEditingMode = true
                            }
                            .onSubmit {
                                onTitleChange(editingTitle)
                                showingRenameField = false
                                isEditingMode = false
                            }
                        
                        HStack {
                            Button("Zrušit") {
                                editingTitle = song.title
                                showingRenameField = false
                                isEditingMode = false
                            }
                            
                            Button("Uložit") {
                                onTitleChange(editingTitle)
                                showingRenameField = false
                                isEditingMode = false
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
                
                Text(song.filename)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Start time
            VStack(spacing: 2) {
                Text("Start")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Button(action: { showingStartTimeField.toggle() }) {
                    Text(formatTime(startTime))
                        .font(.caption)
                        .foregroundStyle(startTime > 0 ? .blue : .secondary)
                        .frame(width: 35, alignment: .center)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingStartTimeField) {
                    VStack(spacing: 12) {
                        Text("Čas začátku")
                            .font(.headline)
                        
                        HStack {
                            Text("Sekund:")
                            TextField("0", value: $startTime, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 60)
                                .onAppear {
                                    isEditingMode = true
                                }
                        }
                        
                        HStack {
                            Button("Zrušit") {
                                startTime = song.startTime
                                showingStartTimeField = false
                                isEditingMode = false
                            }
                            
                            Button("Uložit") {
                                onStartTimeChange(startTime)
                                showingStartTimeField = false
                                isEditingMode = false
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
            }
            
            // Duration
            VStack(spacing: 2) {
                Text("Délka")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(song.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .center)
            }
            
            // Volume control
            VStack(spacing: 2) {
                Text("Hlasitost")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "speaker.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Slider(value: $volume, in: 0...1) { editing in
                        if !editing {
                            onVolumeChange(volume)
                        }
                    }
                    .frame(width: 80)
                    
                    Text("\(Int(volume * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding(.vertical, 4)
        .background(isCurrentSong ? .blue.opacity(0.1) : (isHovering ? .gray.opacity(0.1) : .clear), in: RoundedRectangle(cornerRadius: 8))
        .animation(.easeInOut(duration: 0.2), value: isCurrentSong)
        .animation(.easeInOut(duration: 0.15), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            onPlay()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%ds", Int(seconds))
        }
    }
}