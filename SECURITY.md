# Security Policy

## 🔒 Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | ✅ Yes            |
| < 1.0   | ❌ No             |

## 🚨 Reporting a Vulnerability

VaciPlayer bere bezpečnost vážně. Pokud objevíte bezpečnostní problém, prosím postupujte následovně:

### 📧 Private Reporting
**NEHLASTE** bezpečnostní problémy prostřednictvím public GitHub issues.

**Kontakt:**
- Email: [Create private issue pro security]
- GitHub Security Advisory: Doporučený způsob

### 📋 What to Include
1. **Popis vulnerability** - detailní popis problému
2. **Steps to reproduce** - jak problém reprodukovat
3. **Impact assessment** - potenciální dopad
4. **Suggested fix** - navrhované řešení (pokud máte)

### ⏱️ Response Timeline
- **Acknowledgment**: 48 hodin
- **Initial assessment**: 7 dní
- **Fix timeline**: Závisí na severity
- **Public disclosure**: Po fix release

## 🛡️ Security Measures

### Application Security

#### Code Security
- ✅ **No hardcoded secrets** - žádné API keys nebo hesla v kódu
- ✅ **Input validation** - všechny user inputs jsou validované
- ✅ **Safe file operations** - kontrola file permissions
- ✅ **Memory safety** - Swift memory management

#### File System Security
- ✅ **Sandboxed file access** - pouze user-selected folders
- ✅ **No automatic network access** - žádné síťové operace
- ✅ **Local data only** - žádné cloud uploads
- ✅ **Secure file parsing** - safe MP3 metadata reading

#### User Privacy
- ✅ **No data collection** - žádná analytics nebo tracking
- ✅ **Local storage only** - vše uloženo lokálně
- ✅ **No external connections** - žádné síťové requesty
- ✅ **User control** - user má plnou kontrolu nad daty

### Build Security

#### CI/CD Security
- ✅ **Automated security scans** v GitHub Actions
- ✅ **Dependency checking** - no vulnerable dependencies
- ✅ **Code signing validation** (basic)
- ✅ **Binary verification** - structure validation

#### Source Code Security
- ✅ **Static analysis** - SwiftLint s security rules
- ✅ **Secret detection** - automated secret scanning
- ✅ **Review process** - all changes reviewed

## 🔍 Security Best Practices

### For Users

#### Installation Security
```bash
# Verify downloaded app
# Check file size and basic structure
ls -la VaciPlayer.app/Contents/MacOS/VaciPlayer

# Verify it's a valid macOS app
file VaciPlayer.app/Contents/MacOS/VaciPlayer
```

#### Usage Security
- ⚠️ **Only open trusted MP3 files** - malformed files mohou způsobit problémy
- 🔒 **Check folder permissions** - app potřebuje read access
- 🚫 **Don't run with admin privileges** - není potřeba

### For Developers

#### Development Security
```bash
# Run security checks
grep -r "password\|secret\|key" Sources/ --include="*.swift"

# Check for TODO security items
grep -r "TODO.*security\|FIXME.*security" Sources/ --include="*.swift"

# Validate SwiftLint security rules
swiftlint lint --strict
```

#### Code Review Security
- 🔍 **Review all file operations** - check for unsafe paths
- 🛡️ **Validate user inputs** - especially file paths
- 🚫 **No external dependencies** - avoid unnecessary libs
- 📊 **Check memory usage** - prevent memory leaks

## ⚠️ Known Security Considerations

### Audio File Processing
- **Risk**: Malformed MP3 files
- **Mitigation**: AVFoundation safe parsing
- **Status**: ✅ Managed by system frameworks

### File System Access
- **Risk**: Unauthorized file access
- **Mitigation**: User-selected folders only
- **Status**: ✅ Sandboxed access pattern

### PDF Generation
- **Risk**: PDF content injection
- **Mitigation**: Safe string formatting
- **Status**: ✅ User content only

### Memory Management
- **Risk**: Memory leaks s large playlists
- **Mitigation**: Swift ARC + proper cleanup
- **Status**: ✅ Tested with large files

## 🔧 Security Configuration

### macOS Security Settings
```bash
# Recommended macOS security settings
# System Preferences > Security & Privacy

# Gatekeeper: App Store and identified developers
# Firewall: Enabled (VaciPlayer doesn't need network)
# FileVault: Recommended for file protection
```

### App Permissions
VaciPlayer potřebuje pouze:
- ✅ **File system access** - user-selected folders
- ❌ **Network access** - není potřeba
- ❌ **Camera/Microphone** - není potřeba
- ❌ **Location services** - není potřeba

## 🛠️ Security Updates

### Update Process
1. **Security fix development** - private repository
2. **Testing** - thorough security testing
3. **Release** - immediate release for critical issues
4. **Notification** - GitHub release notes

### Version Management
- **Critical security fixes**: Immediate patch release
- **Non-critical fixes**: Next minor release
- **Security advisories**: GitHub Security Advisories

## 📋 Security Checklist

### For New Features
- [ ] Input validation implemented
- [ ] No new external dependencies
- [ ] File operations are safe
- [ ] Memory usage checked
- [ ] Privacy impact assessed

### For Releases
- [ ] Security scan completed
- [ ] No hardcoded secrets
- [ ] Dependencies updated
- [ ] Change log reviewed for security impact
- [ ] Binary signing verified

## 🔗 Security Resources

### External Security
- [Apple Security Guide](https://support.apple.com/guide/security/)
- [Swift Security Best Practices](https://swift.org/security/)
- [macOS Hardening Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)

### Internal Security
- [CI/CD Security](docs/CI_CD.md#security-job)
- [Contributing Guidelines](CONTRIBUTING.md#security-guidelines)
- [Code Review Process](CONTRIBUTING.md#pull-requests)

---

## 📞 Security Contact

Pro security-related otázky nebo reports:
- **GitHub Security Advisories**: Preferred method
- **Private communication**: Pro sensitive issues

**Response commitment:**
- Acknowledgment within 48 hours
- Status update within 7 days
- Fix timeline based on severity

Děkujeme za pomoc s udržováním VaciPlayer bezpečného! 🔒