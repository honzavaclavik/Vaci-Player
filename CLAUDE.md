# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Running
```bash
# Standard development build
swift build

# Run from command line (development)
swift run   

# Create standalone macOS app (recommended for testing)
./build_standalone_app.sh
```

### Testing
```bash
# Run tests
swift test
```

## Architecture Overview

VaciPlayer is a native macOS MP3 player built with SwiftUI for macOS 14+. It uses Swift Package Manager and follows the MVVM pattern with ObservableObject models.

### Core Architecture Components

**Models** (`Sources/VaciPlayer/Models/`):
- `Playlist.swift` - Central state manager with @Published properties for songs, current index, folder path, pause settings, and master volume. Handles persistence via UserDefaults with folder-specific keys.
- `Song.swift` - Represents MP3 files with metadata (title, volume, order, duration, startTime). Uses AVAsset for duration loading.
- `FavoriteFolder.swift` - Manages saved folder references with custom names.

**Services** (`Sources/VaciPlayer/Services/`):
- `AudioManager.swift` - Handles AVAudioPlayer lifecycle, volume control (individual vs effective volume), and playback state. Listens to folder change notifications to stop playback.
- `FolderManager.swift` - Manages favorite folders persistence and operations.

**Views** (`Sources/VaciPlayer/Views/`):
- `ContentView.swift` - Main coordinator with keyboard handling (space, enter, arrows, escape).
- `SidebarView.swift` - Navigation with folder selection, favorites list, stats, and settings sliders.
- `PlaylistView.swift` - Song list with drag & drop reordering, individual volume controls, and start time popover settings.
- `PlayerControlsView.swift` - Transport controls, progress slider, and master volume control.

### Key Data Flow Patterns

**Volume System** - Three-tier volume control:
1. Individual song volume (stored per song)
2. Master volume multiplier (stored per folder)
3. Effective volume = min(1.0, song.volume * masterVolume)

**Persistence Strategy**:
- Folder-specific data uses URL hash as key: `"playlist_\(folderPath.absoluteString.hash)"`
- Master volume per folder: `"masterVolume_\(folderPath.absoluteString.hash)"`
- Global settings use direct keys: `"pauseBetweenSongs"`, `"currentSongIndex"`

**State Synchronization**:
- `loadSongs()` saves current folder state before switching, then loads new folder data
- UI updates triggered via `objectWillChange.send()` for immediate slider updates
- AudioManager tracks both displayed volume and effective volume separately

### Keyboard Controls
- **Space**: Next song (or play first if none active)
- **Enter**: Restart current song from configured start time
- **↑**: Previous song (loops to end)
- **↓**: Next song (loops to beginning)  
- **Escape**: Pause if playing

### Build System
- Uses Swift Package Manager with macOS 14.0 minimum target
- `build_standalone_app.sh` creates native .app bundle using swiftc directly
- No external dependencies - uses only system frameworks (SwiftUI, AVFoundation, AppKit)

### Important Implementation Details
- Song start times allow skipping intros/outros
- Drag & drop reordering updates song.order and persists immediately
- Folder switching automatically stops playback and saves state
- Duration calculation includes configurable pause times between songs
- All text is in Czech language