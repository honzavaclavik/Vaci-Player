# VaciPlayer for macOS

A modern MP3 player built for macOS 14+ using SwiftUI.

## Features

### 🎵 Playback & Controls
✅ **MP3 file playback** from a selected folder
✅ **Individual volume** for each file
✅ **Playback speed control** (0.5x to 2.0x) without affecting pitch
✅ **Pitch/tuning control** (-12 to +12 semitones) without affecting speed
✅ **Loop playback** - set loop points on the waveform for practice/rehearsal
✅ **Advanced keyboard controls** - full set of shortcuts
✅ **Start time setting** - skip intros/outros
✅ **Master volume** per folder

### 📱 UI & Organization
✅ **Waveform visualization** with zoom, pan, and click-to-seek
✅ **Drag & Drop** to reorder songs
✅ **Favorite folders** - quick switching between folders
✅ **Modern macOS design** with glassmorphism effects
✅ **Sidebar navigation** for folder selection
✅ **Dark/Light mode** support
✅ **PDF export** of the playlist for the band with custom song titles

### 💾 Persistence & Automation
✅ **Persistent settings** - everything is saved per folder
✅ **Automatic state restoration** on app restart
✅ **Song durations** - displayed in mm:ss format
✅ **Total set duration** - with configurable pause between songs

## System Requirements

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## Installation & Running

### Homebrew (recommended):
```bash
# Install via Homebrew
brew tap honzavaclavik/honzavaclavik
brew install --cask vaci-player

# Update
brew upgrade --cask vaci-player
```

**⚠️ Important - first launch:**
On first launch of the Homebrew-installed app, a warning about an unverified application will appear. To allow the app:

1. **Click "Cancel"** when the warning appears
2. **Go to System Preferences → Security & Privacy → General**
3. **Click "Open Anyway"** next to the VaciPlayer message
4. **Or use the command:**
   ```bash
   sudo xattr -rd com.apple.quarantine /Applications/VaciPlayer.app
   ```

### Standalone macOS app (development):
```bash
# Build VaciPlayer.app
./build_standalone_app.sh

# Then launch by double-clicking VaciPlayer.app
```

### From the command line (development):
```bash
# Build the project
swift build

# Run
swift run
```

## Usage

### Basic Controls
1. **Select a folder**:
   - Click "Choose Folder" in the sidebar, OR
   - Use the menu "File → Open Folder..." (Cmd+O)
2. **Favorite folders**: Folders are automatically added to favorites, click them to quickly switch
3. **Rename**: Hover over a favorite folder and click the pencil icon
4. **Remove**: Hover over a favorite folder and click the X icon
5. **Playback**: Click the play icon next to the desired song
6. **Volume**: Adjust the slider for individual songs
7. **Reorder**: Drag songs in the list to change their order

### Advanced Features
8. **Playback speed**: Use the +/- buttons or keys `+`, `-`, `=` (reset)
9. **Pitch/Tuning**: Use the +/- buttons or keys `[`, `]`, `\` (reset)
10. **Start time**: Click on the time next to a song to set the start position
11. **PDF export**: Export the playlist with custom names for the band
12. **Pause between songs**: Set the pause between songs using the slider (0-5 minutes)

### Keyboard Shortcuts
- **Space**: Next song (or start the first one)
- **Enter**: Restart current song from start time
- **↑/↓**: Previous/Next song (with loop)
- **Escape**: Pause
- **0-9**: Jump to percentage of song (0% - 90%)
- **+/-/=**: Playback speed (increase/decrease/reset)
- **[/]/\\**: Pitch tuning (decrease/increase/reset)

### Quit
- Menu "VaciPlayer → Quit VaciPlayer" (Cmd+Q)

## Architecture

```
Sources/VaciPlayer/
├── VaciPlayerApp.swift         # Entry point (@main)
├── AppDelegate.swift           # Application delegate, menu commands
├── Models/
│   ├── Song.swift              # MP3 file model
│   ├── Playlist.swift          # Playlist model
│   └── FavoriteFolder.swift    # Favorite folders model
├── Services/
│   ├── AudioManager.swift      # Audio playback management
│   ├── FolderManager.swift     # Favorite folders management
│   └── PDFExportManager.swift  # PDF playlist export
└── Views/
    ├── ContentView.swift       # Main view with keyboard handling
    ├── SidebarView.swift       # Navigation sidebar with favorite folders
    ├── MainPlayerView.swift    # Coordinator: playlist + waveform + controls
    ├── PlaylistView.swift      # Song list with drag & drop
    ├── PlayerControlsView.swift # Playback controls
    ├── WaveformView.swift      # Waveform visualization with zoom & loop
    └── FavoriteFolderRowView.swift # Favorite folder row
```

## Key Technologies

### Audio Engine
- **AVAudioEngine + AVAudioTimePitchEffect**: Advanced audio processing with independent speed and pitch control
- **AVAudioPlayerNode**: Precise playback control with loop support
- **AVAsset**: Loading metadata and MP3 file durations

### UI & UX
- **SwiftUI + macOS 14+**: Modern UI framework with the latest features
- **Waveform Display**: Visual waveform with zoom (1x-20x), pan, click-to-seek, and loop selection
- **Hover Effects**: Modern mouse interactions for better UX
- **Drag & Drop**: Native support for reordering
- **Native macOS App**: Launch without Terminal with menu bar integration

### Persistence & Data Management
- **UserDefaults**: Sophisticated per-folder storage (volume, order, speed, pitch, pauses)
- **File System Integration**: Native integration with the macOS file system
- **Real-time Calculations**: Dynamic total duration calculation including pauses
- **PDF Generation**: Playlist export for the band

## License

MIT License - see LICENSE file
