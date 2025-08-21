# CI/CD Documentation

VaciPlayer používá GitHub Actions pro automatizované testování a deployment.

## 🔄 Continuous Integration (CI)

### Workflow: `.github/workflows/ci.yml`

**Trigger:**
- Push na `main` a `develop` branches
- Pull requesty na `main` branch

**Jobs:**

#### 1. **Test Job**
- ✅ Build validation (debug + release)
- ✅ App bundle creation
- ✅ Structure verification
- ✅ Icon validation
- ✅ Info.plist checks
- 📦 Upload artifacts for 7 days

#### 2. **Lint Job**
- 🔍 SwiftLint static analysis
- 📊 Code quality checks
- ⚠️ Continues on errors (non-blocking)

#### 3. **Security Job**
- 🔐 Hardcoded secrets detection
- 🚨 Security TODO detection
- 🛡️ Basic security patterns check

#### 4. **Documentation Job**
- 📖 README.md validation
- 📋 CLAUDE.md existence check
- 📝 Basic content verification

#### 5. **Performance Job**
- 📏 Binary size monitoring
- ⚡ Release build optimization check
- 📊 Size trend analysis

#### 6. **Compatibility Job**
- 🍎 macOS version requirement check
- 📱 Platform compatibility validation

## 🚀 Release Automation

### Workflow: `.github/workflows/release.yml`

**Trigger:**
- Git tags matching `v*` pattern
- Manual dispatch with version input

**Process:**
1. 🏗️ Build release version
2. 🧪 Run full test suite
3. 📦 Create distributable ZIP
4. 📝 Generate release notes
5. 🚀 Create GitHub release
6. 📤 Upload artifacts

### Release Notes Template

Automaticky generované release notes obsahují:
- ✨ Feature highlights
- 📋 System requirements
- 📥 Installation instructions
- ⌨️ Keyboard shortcuts
- 🎸 Usage tips

## 🧪 Testing Strategy

### Local Testing
```bash
# Run basic functionality tests
./scripts/test_basic_functionality.sh

# Manual build verification
swift build --configuration release
./build_standalone_app.sh
```

### Automated Testing
- **Build Tests**: Compilation v debug i release módu
- **Structure Tests**: Ověření app bundle struktury
- **Integration Tests**: Basic functionality validation
- **Security Tests**: Static analysis pro security issues

### Test Coverage
- ✅ Core build process
- ✅ App bundle creation
- ✅ Icon generation and integration
- ✅ Info.plist configuration
- ✅ Binary structure validation
- ✅ File system operations

## 📊 Quality Checks

### SwiftLint Configuration
```yaml
# .swiftlint.yml
line_length: 120
function_body_length: 60
type_body_length: 300

custom_rules:
  - no_hardcoded_secrets
  - proper_spacing_operators
```

### Security Patterns
- 🚫 No hardcoded passwords/secrets
- 🔍 Pattern detection for sensitive data
- 📝 Security TODO tracking

## 🔧 Development Workflow

### Pre-commit Checklist
- [ ] `swift build` passes
- [ ] `./build_standalone_app.sh` succeeds
- [ ] No SwiftLint warnings
- [ ] Manual testing completed
- [ ] Security review done

### Pull Request Process
1. 🌟 Create feature branch
2. 🔨 Implement changes
3. 🧪 Local testing
4. 📝 Create PR using template
5. ✅ CI validation
6. 👥 Code review
7. 🚀 Merge to main

## 📦 Artifact Management

### Build Artifacts
- **Development**: 7 days retention
- **Release**: 30 days retention
- **Format**: ZIP archives containing .app bundle

### Release Assets
- `VaciPlayer-{version}.zip` - distributable package
- Automatic versioning from git tags
- GitHub Releases integration

## 🚨 Troubleshooting

### Common CI Issues

**Build Failures:**
```bash
# Local reproduction
swift build --configuration release
```

**SwiftLint Failures:**
```bash
# Install SwiftLint
brew install swiftlint

# Run locally
swiftlint lint --strict
```

**Bundle Creation Issues:**
```bash
# Test app bundle creation
./build_standalone_app.sh
./scripts/test_basic_functionality.sh
```

### Performance Monitoring
- Binary size alerts při >50MB
- Build time monitoring
- Dependency analysis

## 📈 Metrics & Monitoring

### Build Metrics
- ⏱️ Build duration tracking
- 📏 Binary size evolution
- 🔄 Success rate monitoring

### Quality Metrics
- SwiftLint violations trend
- Security issues tracking
- Documentation coverage

---

## 🔗 Related Documentation
- [Contributing Guidelines](../CONTRIBUTING.md)
- [Security Policy](../SECURITY.md)
- [Development Setup](../README.md#development)