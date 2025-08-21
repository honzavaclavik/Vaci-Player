# Contributing to VaciPlayer

Děkujeme za zájem o přispění do VaciPlayer! 🎸

## 🚀 Quick Start

1. **Fork** tento repository
2. **Clone** váš fork: `git clone https://github.com/your-username/player.git`
3. **Build** projekt: `swift build`
4. **Test** funkcionalitu: `./scripts/test_basic_functionality.sh`

## 🎯 Types of Contributions

### 🐛 Bug Reports
- Použijte [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)
- Včetně kroků pro reprodukci
- Specifikujte prostředí (macOS verze, hardware)

### ✨ Feature Requests
- Použijte [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)
- Popište use case pro guitar practice
- Navrhněte UI/UX řešení

### 🔧 Code Contributions
- Použijte [Pull Request template](.github/pull_request_template.md)
- Followujte coding standards
- Přidejte testy kde to dává smysl

## 📋 Development Guidelines

### Prerequisites
- **macOS 14.0+** (Sonoma)
- **Xcode 15.0+** s Command Line Tools
- **Swift 5.9+**

### Setup
```bash
# Clone repository
git clone https://github.com/your-username/player.git
cd player

# Build project
swift build

# Create standalone app
./build_standalone_app.sh

# Run tests
./scripts/test_basic_functionality.sh
```

### Code Style

#### SwiftLint
```bash
# Install SwiftLint
brew install swiftlint

# Run linting
swiftlint lint --strict
```

#### Naming Conventions
- **Classes**: `PascalCase` (e.g., `AudioManager`)
- **Functions**: `camelCase` (e.g., `updateSongVolume`)
- **Variables**: `camelCase` (e.g., `currentSongIndex`)
- **Constants**: `camelCase` (e.g., `maxVolume`)

#### Comments
- **Czech language** pro user-facing strings
- **English** pro code comments a dokumentaci
- Minimal comments - code should be self-documenting

### Architecture Patterns

#### MVVM Structure
```
Sources/VaciPlayer/
├── Models/          # Data models (Song, Playlist, etc.)
├── Views/           # SwiftUI views
├── Services/        # Business logic (AudioManager, etc.)
└── VaciPlayerApp.swift
```

#### State Management
- `@ObservableObject` pro shared state
- `@Published` properties pro UI updates
- UserDefaults pro persistence

### Testing

#### Local Testing
```bash
# Basic functionality
./scripts/test_basic_functionality.sh

# Manual testing checklist
- [ ] Audio playback works
- [ ] Drag & drop reordering
- [ ] PDF export functionality
- [ ] Keyboard shortcuts
- [ ] Volume controls
```

#### UI Testing Guidelines
- Test with různé screen sizes
- Verify hover states
- Check accessibility

### Git Workflow

#### Branch Naming
- `feature/short-description` - nové features
- `bugfix/issue-description` - bug fixes
- `hotfix/critical-issue` - critical fixes

#### Commit Messages
```
feat: add PDF export functionality
fix: resolve drag and drop conflict with tap gesture
docs: update installation instructions
style: fix SwiftLint warnings
refactor: extract audio player logic to service
```

#### Pull Requests
1. **Create feature branch** z `main`
2. **Make changes** s atomic commits
3. **Test locally** - build, functionality, manual testing
4. **Create PR** using template
5. **Address review feedback**
6. **Squash and merge** po approval

## 🎸 VaciPlayer Specific Guidelines

### Audio Features
- Test s real MP3 files (various bitrates)
- Verify performance s large playlists (50+ songs)
- Test audio výstup (speakers, headphones, USB interfaces)

### PDF Export
- Test s různým počtem songs (1-50)
- Verify font scaling
- Check PDF formatting on různých systémech

### Keyboard Shortcuts
- Maintain existing shortcuts
- Document new shortcuts
- Test v různých app states

### File Management
- Support for network drives
- Handle file permission issues gracefully
- Preserve user data při folder changes

## 🚨 Security Guidelines

### Code Security
- **No hardcoded secrets** - use environment variables
- **Validate all inputs** - file paths, user input
- **Secure file operations** - check permissions

### User Data
- **Minimal data collection** - only necessary for functionality
- **Local storage only** - no cloud uploads
- **User control** - clear data management

## 📊 Performance Guidelines

### Optimization Targets
- **Startup time**: < 2 seconds
- **Memory usage**: < 100MB for typical playlists
- **CPU usage**: Minimal when not playing audio

### Profiling
```bash
# Build optimized version
swift build --configuration release

# Check binary size
ls -lh .build/release/VaciPlayer

# Profile memory usage during development
```

## 📖 Documentation

### Code Documentation
- Document public APIs
- Include usage examples
- Update CLAUDE.md for architecture changes

### User Documentation
- Update README pro new features
- Create usage examples
- Document keyboard shortcuts

## ✅ Pre-submission Checklist

### Code Quality
- [ ] SwiftLint passes bez warnings
- [ ] Code follows established patterns
- [ ] No debug print statements
- [ ] Error handling implemented

### Functionality
- [ ] Feature works as expected
- [ ] No regressions in existing features
- [ ] Tested on target macOS version
- [ ] Keyboard shortcuts work

### Documentation
- [ ] Code changes documented
- [ ] README updated if needed
- [ ] CLAUDE.md updated for architecture changes
- [ ] PR template filled out

### Testing
- [ ] `./scripts/test_basic_functionality.sh` passes
- [ ] Manual testing completed
- [ ] Performance impact assessed
- [ ] Accessibility considered

## 🤝 Community Guidelines

### Communication
- **Be respectful** a constructive
- **Focus on code** not personality
- **Help others learn** - explain reasoning

### Issue Management
- **Search existing issues** before creating new ones
- **Provide context** - screenshots, logs, steps
- **Follow up** na your reports

## 🎯 Roadmap Contributions

### High Priority Areas
- Audio format support expansion
- Performance optimizations
- Accessibility improvements
- Advanced PDF customization

### Feature Requests Welcome
- Integration s guitar software
- Advanced practice features
- Enhanced file organization
- Automation capabilities

---

## 📞 Getting Help

- **Issues**: Use GitHub issues pro bugs a features
- **Discussions**: Pro general questions a ideas
- **Documentation**: Check README a CLAUDE.md

Děkujeme za vaši pomoc s VaciPlayer! 🎵