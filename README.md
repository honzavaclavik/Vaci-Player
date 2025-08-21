# VaciPlayer pro macOS

Moderní MP3 přehrávač postavený pro macOS 14+ s využitím SwiftUI.

## Funkce

✅ **Přehrávání MP3 souborů** ze zvolené složky  
✅ **Individuální hlasitost** pro každý soubor  
✅ **Drag & Drop** pro změnu pořadí písniček  
✅ **Perzistentní nastavení** - hlasitost a pořadí se ukládají  
✅ **Oblíbené složky** - rychlé přepínání mezi složkami  
✅ **Automatické obnovení stavu** při restartu aplikace  
✅ **Délky písniček** - zobrazení v mm:ss formátu  
✅ **Celková délka setu** - s nastavitelnou prodlevou mezi písničkami  
✅ **Moderní macOS design** s glassmorphism efekty  
✅ **Sidebar navigace** pro výběr složek  
✅ **Dark/Light mode** podpora  

## Systémové požadavky

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## Instalace a spuštění

### Standalone macOS aplikace (doporučeno):
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

1. **Výběr složky**: 
   - Klikněte na "Choose Folder" v sidebaru, NEBO
   - Použijte menu "File → Open Folder..." (Cmd+O)
2. **Oblíbené složky**: Složky se automaticky přidají do oblíbených, klikněte na ně pro rychlé přepnutí
3. **Přejmenování**: Najeďte myší na oblíbenou složku a klikněte na ikonu tužky
4. **Odstranění**: Najeďte myší na oblíbenou složku a klikněte na ikonu X
5. **Přehrávání**: Klikněte na ikonu play u vybrané písničky
6. **Hlasitost**: Upravte slider u jednotlivých písniček
7. **Přeuspořádání**: Táhněte písničky v seznamu pro změnu pořadí
8. **Prodleva**: Nastavte pauzu mezi písničkami pomocí slideru (0-5 minut)
9. **Délky**: Zobrazují se automaticky po načtení MP3 souborů
10. **Ovládání**: Použijte spodní ovládací panel
11. **Ukončení**: Menu "VaciPlayer → Quit VaciPlayer" (Cmd+Q)

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

## Klíčové vlastnosti

- **SwiftUI + macOS 14+**: Moderní UI framework s nejnovějšími funkcemi
- **AVAudioPlayer**: Spolehlivé přehrávání audio souborů  
- **AVAsset**: Načítání metadat a délek MP3 souborů
- **UserDefaults**: Perzistence nastavení hlasitosti, pořadí, oblíbených složek a prodlev
- **File System Integration**: Nativní integrace s macOS file systemem
- **Hover Effects**: Moderní interakce s myší pro lepší UX
- **Real-time Calculations**: Dynamický výpočet celkové délky včetně prodlev
- **Native macOS App**: Spuštění bez Terminálu s menu bar integrací

## Licence

MIT License - viz LICENSE soubor