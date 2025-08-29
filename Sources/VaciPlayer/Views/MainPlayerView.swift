import SwiftUI

struct MainPlayerView: View {
    @ObservedObject var playlist: Playlist
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var audioInputManager: AudioInputManager
    @Binding var isEditingMode: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if playlist.songs.isEmpty {
                EmptyStateView()
            } else {
                // Playlist
                PlaylistView(playlist: playlist, audioManager: audioManager, isEditingMode: $isEditingMode)
                
                Divider()
                
                // Waveform View
                if let currentSong = playlist.currentSong {
                    WaveformView(song: currentSong, audioManager: audioManager)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 0))
                    
                    Divider()
                }
                
                // Player Controls
                PlayerControlsView(playlist: playlist, audioManager: audioManager)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 0))
            }
            
            // Minimal Guitar Amp Panel (at the bottom, toggleable)
            if audioInputManager.isPanelVisible {
                MinimalGuitarAmpView(audioInputManager: audioInputManager)
                    .padding(.horizontal)
            }
        }
        // .animation(.easeInOut(duration: 0.3), value: audioInputManager.isPanelVisible) // DISABLED FOR STABILITY
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("Není vybrána hudba")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Vyberte složku z postranního panelu pro spuštění přehrávání")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}