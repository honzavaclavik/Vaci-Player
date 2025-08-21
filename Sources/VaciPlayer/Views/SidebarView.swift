import SwiftUI

struct SidebarView: View {
    @ObservedObject var playlist: Playlist
    @ObservedObject var folderManager: FolderManager
    @ObservedObject var audioManager: AudioManager
    @Binding var showingFolderPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "music.note")
                    .foregroundStyle(.primary)
                    .font(.title2)
                
                Text("VaciPlayer")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
            
            // Folder Section
            VStack(alignment: .leading, spacing: 8) {
                Label("Složka s hudbou", systemImage: "folder.fill")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Button(action: { showingFolderPicker = true }) {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text(playlist.folderPath?.lastPathComponent ?? "Vybrat složku")
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            
            // Favorite Folders Section
            if !folderManager.favoriteFolders.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Oblíbené složky", systemImage: "heart.fill")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Add current folder to favorites button
                        if let currentFolder = playlist.folderPath,
                           !folderManager.isFavorite(currentFolder) {
                            Button(action: {
                                folderManager.addFavoriteFolder(currentFolder)
                            }) {
                                Image(systemName: "heart.badge.plus")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(folderManager.favoriteFolders) { folder in
                                FavoriteFolderRowView(
                                    folder: folder,
                                    isSelected: folder.url == playlist.folderPath,
                                    onSelect: {
                                        playlist.loadSongs(from: folder.url)
                                    },
                                    onRemove: {
                                        folderManager.removeFavoriteFolder(folder)
                                    },
                                    onRename: { newName in
                                        folderManager.updateFolderName(folder, newName: newName)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            if !playlist.songs.isEmpty {
                Divider()
                
                // Stats and Settings
                VStack(alignment: .leading, spacing: 8) {
                    // Songs count and total duration
                    VStack(alignment: .leading, spacing: 4) {
                        Label("\(playlist.songs.count) skladeb", systemImage: "music.note.list")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Label(playlist.formattedTotalDuration, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Pause between songs setting
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Pauza mezi skladbami", systemImage: "pause.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            Slider(value: $playlist.pauseBetweenSongs, in: 0...5, step: 0.1) { editing in
                                if !editing {
                                    // Save when user stops editing
                                    playlist.savePauseBetweenSongs()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Text(String(format: "%.1f min", playlist.pauseBetweenSongs))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 45, alignment: .trailing)
                        }
                    }
                    
                    // Master volume setting
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Hlasitost složky", systemImage: "speaker.wave.3")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            Slider(value: $playlist.masterVolumeMultiplier, in: 0...2, step: 0.1) { editing in
                                if !editing {
                                    // Update current master volume if playing
                                    audioManager.updateMasterVolume(playlist.masterVolumeMultiplier)
                                    // Save master volume for current folder
                                    playlist.saveMasterVolume()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Text("\(Int(playlist.masterVolumeMultiplier * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(minWidth: 200, maxWidth: 250)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 0))
    }
}