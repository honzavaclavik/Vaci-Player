# VaciPlayer pro macOS

Moderní MP3 přehrávač postavený pro macOS 14+ s využitím SwiftUI.

## Funkce

### 🎵 Přehrávání a ovládání
✅ **Přehrávání MP3 souborů** ze zvolené složky  
✅ **Individuální hlasitost** pro každý soubor  
✅ **Změna rychlosti přehrávání** (0.5x až 2.0x) bez změny ladění  
✅ **Změna pitch/ladění** (-12 až +12 půltónů) bez změny rychlosti  
✅ **Pokročilé ovládání klávesnicí** - kompletní sada zkratek  
✅ **Start time nastavení** - přeskočení intros/outros  
✅ **Master volume** per složka  

### 📱 UI a organizace
✅ **Drag & Drop** pro změnu pořadí písniček  
✅ **Oblíbené složky** - rychlé přepínání mezi složkami  
✅ **Moderní macOS design** s glassmorphism efekty  
✅ **Sidebar navigace** pro výběr složek  
✅ **Dark/Light mode** podpora  
✅ **PDF export** playlistu pro kapelu  

### 💾 Perzistence a automatizace
✅ **Perzistentní nastavení** - vše se ukládá per složka  
✅ **Automatické obnovení stavu** při restartu aplikace  
✅ **Délky písniček** - zobrazení v mm:ss formátu  
✅ **Celková délka setu** - s nastavitelnou prodlevou mezi písničkami  

## Systémové požadavky

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## Instalace a spuštění

### Homebrew (doporučeno):
```bash
# Instalace přes Homebrew
brew tap honzavaclavik/honzavaclavik
brew install --cask vaci-player

# Aktualizace
brew upgrade --cask vaci-player
```

**⚠️ Důležité - první spuštění:**
Při prvním spuštění aplikace z Homebrew se zobrazí varování o neověřené aplikaci. Pro povolení aplikace:

1. **Klikněte "Zrušit"** když se zobrazí varování
2. **Jděte do System Preferences → Security & Privacy → General**
3. **Klikněte "Open Anyway"** u zprávy o VaciPlayer
4. **Nebo použijte příkaz:**
   ```bash
   sudo xattr -rd com.apple.quarantine /Applications/VaciPlayer.app
   ```

### Standalone macOS aplikace (development):
```bash
# Vytvořit VaciPlayer.app
./build_standalone_app.sh

# Poté spustit dvojklikem na VaciPlayer.app
```

### Z příkazové řádky (development):
```bash
# Build projektu
swift build

# Spuštění
swift run
```

## Použití

### Základní ovládání
1. **Výběr složky**: 
   - Klikněte na "Choose Folder" v sidebaru, NEBO
   - Použijte menu "File → Open Folder..." (Cmd+O)
2. **Oblíbené složky**: Složky se automaticky přidají do oblíbených, klikněte na ně pro rychlé přepnutí
3. **Přejmenování**: Najeďte myší na oblíbenou složku a klikněte na ikonu tužky
4. **Odstranění**: Najeďte myší na oblíbenou složku a klikněte na ikonu X
5. **Přehrávání**: Klikněte na ikonu play u vybrané písničky
6. **Hlasitost**: Upravte slider u jednotlivých písniček
7. **Přeuspořádání**: Táhněte písničky v seznamu pro změnu pořadí

### Pokročilé funkce
8. **Rychlost přehrávání**: Použijte +/- tlačítka nebo klávesy `+`, `-`, `=` (reset)
9. **Pitch/Ladění**: Použijte +/- tlačítka nebo klávesy `[`, `]`, `\` (reset)
10. **Start time**: Klikněte na čas u písničky pro nastavení začátku
11. **PDF export**: Export playlistu s vlastními názvy pro kapelu
12. **Prodleva**: Nastavte pauzu mezi písničkami pomocí slideru (0-5 minut)

### Klávesové zkratky
- **Space**: Další písnička (nebo spuštění první)
- **Enter**: Restart aktuální písničky od start time
- **↑/↓**: Předchozí/Další písnička (s loop)
- **Escape**: Pauza
- **0-9**: Skok na procenta písničky (0% - 90%)
- **+/-/=**: Rychlost přehrávání (zvýšit/snížit/reset)
- **[/]/\\**: Pitch ladění (snížit/zvýšit/reset)

### Ukončení
- Menu "VaciPlayer → Quit VaciPlayer" (Cmd+Q)

## Architektura

```
Sources/VaciPlayer/
├── main.swift              # Entry point
├── Models/
│   ├── Song.swift          # Model pro MP3 soubor
│   ├── Playlist.swift      # Model pro playlist
│   └── FavoriteFolder.swift # Model pro oblíbené složky
├── Services/
│   ├── AudioManager.swift  # Správa audio přehrávání
│   └── FolderManager.swift # Správa oblíbených složek
└── Views/
    ├── ContentView.swift   # Hlavní view
    ├── SidebarView.swift   # Navigační sidebar s oblíbenými složkami
    ├── MainPlayerView.swift
    ├── PlaylistView.swift  # Seznam písniček
    ├── PlayerControlsView.swift # Ovládací prvky
    └── FavoriteFolderRowView.swift # Řádek oblíbené složky
```

## Klíčové technologie

### Audio Engine
- **AVAudioEngine + AVAudioTimePitchEffect**: Pokročilé audio zpracování s nezávislou změnou rychlosti a pitch
- **AVAudioPlayerNode**: Precizní ovládání přehrávání
- **AVAsset**: Načítání metadat a délek MP3 souborů

### UI a UX  
- **SwiftUI + macOS 14+**: Moderní UI framework s nejnovějšími funkcemi
- **Hover Effects**: Moderní interakce s myší pro lepší UX
- **Drag & Drop**: Nativní podpora pro přeuspořádání
- **Native macOS App**: Spuštění bez Terminálu s menu bar integrací

### Perzistence a správa dat
- **UserDefaults**: Sofistikované ukládání per složka (hlasitost, pořadí, rychlost, pitch, prodlevy)
- **File System Integration**: Nativní integrace s macOS file systemem
- **Real-time Calculations**: Dynamický výpočet celkové délky včetně prodlev
- **PDF Generation**: Export playlistů pro kapelu

## Licence

MIT License - viz LICENSE soubor