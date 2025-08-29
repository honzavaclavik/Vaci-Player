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
            
            // Playback rate control
            HStack {
                Button(action: { 
                    audioManager.decreasePlaybackRate()
                    playlist.playbackRate = audioManager.playbackRate
                    playlist.savePlaybackRate()
                }) {
                    Image(systemName: "minus.circle")
                }
                .disabled(audioManager.playbackRate <= 0.5)
                
                VStack(spacing: 2) {
                    Text("Rychlost")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1fx", audioManager.playbackRate))")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(minWidth: 50)
                
                Button(action: { 
                    audioManager.increasePlaybackRate()
                    playlist.playbackRate = audioManager.playbackRate
                    playlist.savePlaybackRate()
                }) {
                    Image(systemName: "plus.circle")
                }
                .disabled(audioManager.playbackRate >= 2.0)
                
                Button(action: { 
                    audioManager.resetPlaybackRate()
                    playlist.playbackRate = audioManager.playbackRate
                    playlist.savePlaybackRate()
                }) {
                    Text("Reset")
                        .font(.caption)
                }
                .disabled(audioManager.playbackRate == 1.0)
            }
            
            // Pitch control
            HStack {
                Button(action: { 
                    audioManager.decreasePitch()
                    playlist.pitch = audioManager.pitch
                    playlist.savePitch()
                }) {
                    Image(systemName: "minus.circle")
                }
                .disabled(audioManager.pitch <= -12.0)
                
                VStack(spacing: 2) {
                    Text("Ladění")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(formatPitch(audioManager.pitch))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(minWidth: 60)
                
                Button(action: { 
                    audioManager.increasePitch()
                    playlist.pitch = audioManager.pitch
                    playlist.savePitch()
                }) {
                    Image(systemName: "plus.circle")
                }
                .disabled(audioManager.pitch >= 12.0)
                
                Button(action: { 
                    audioManager.resetPitch()
                    playlist.pitch = audioManager.pitch
                    playlist.savePitch()
                }) {
                    Text("Reset")
                        .font(.caption)
                }
                .disabled(audioManager.pitch == 0.0)
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
                // If the song is already loaded, just resume
                if audioManager.isSongLoaded(currentSong) {
                    audioManager.resume()
                } else {
                    // Load and play new song
                    audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier, playbackRate: audioManager.playbackRate, pitch: audioManager.pitch)
                    audioManager.play()
                }
            }
        }
    }
    
    private func previousSong() {
        guard playlist.currentSongIndex > 0 else { return }
        playlist.setCurrentSongIndex(playlist.currentSongIndex - 1)
        if let currentSong = playlist.currentSong {
            audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier, playbackRate: audioManager.playbackRate, pitch: audioManager.pitch)
            if audioManager.isPlaying {
                audioManager.play()
            }
        }
    }
    
    private func nextSong() {
        guard playlist.currentSongIndex < playlist.songs.count - 1 else { return }
        playlist.setCurrentSongIndex(playlist.currentSongIndex + 1)
        if let currentSong = playlist.currentSong {
            audioManager.loadSong(currentSong, masterVolume: playlist.masterVolumeMultiplier, playbackRate: audioManager.playbackRate, pitch: audioManager.pitch)
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
    
    private func formatPitch(_ pitch: Float) -> String {
        if pitch == 0 {
            return "0"
        } else if pitch > 0 {
            return "+\(String(format: "%.1f", pitch))"
        } else {
            return String(format: "%.1f", pitch)
        }
    }
}