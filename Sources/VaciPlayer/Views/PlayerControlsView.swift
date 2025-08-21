import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var playlist: Playlist
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Current song info
            if let currentSong = playlist.currentSong {
                VStack(spacing: 4) {
                    Text(currentSong.displayTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(currentSong.filename)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            // Progress bar
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { audioManager.currentTime },
                        set: { audioManager.seek(to: $0) }
                    ),
                    in: 0...max(audioManager.duration, 1)
                )
                
                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(audioManager.duration))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Transport controls
            HStack(spacing: 20) {
                Button(action: previousSong) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .disabled(playlist.currentSongIndex <= 0)
                
                Button(action: togglePlayPause) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                .disabled(playlist.currentSong == nil)
                
                Button(action: nextSong) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .disabled(playlist.currentSongIndex >= playlist.songs.count - 1)
            }
            
            // Master volume
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundStyle(.secondary)
                
                Slider(value: $audioManager.volume, in: 0...1) { editing in
                    if !editing {
                        // Update current song volume in playlist
                        if let currentSong = playlist.currentSong {
                            playlist.updateSongVolume(currentSong, volume: audioManager.volume)
                        }
                        audioManager.setVolume(audioManager.volume)
                    }
                }
                
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: 400)
    }
    
    private func togglePlayPause() {
        if audioManager.isPlaying {
            audioManager.pause()
        } else {
            if let currentSong = playlist.currentSong {
                audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier)
                audioManager.play()
            }
        }
    }
    
    private func previousSong() {
        guard playlist.currentSongIndex > 0 else { return }
        playlist.setCurrentSongIndex(playlist.currentSongIndex - 1)
        if let currentSong = playlist.currentSong {
            audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier)
            if audioManager.isPlaying {
                audioManager.play()
            }
        }
    }
    
    private func nextSong() {
        guard playlist.currentSongIndex < playlist.songs.count - 1 else { return }
        playlist.setCurrentSongIndex(playlist.currentSongIndex + 1)
        if let currentSong = playlist.currentSong {
            audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier)
            if audioManager.isPlaying {
                audioManager.play()
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}