# Homebrew Distribuce

## Krok 1: Vytvoření GitHub Release

1. Spusťte release script:
   ```bash
   ./release.sh 1.0.0
   ```

2. Vytvořte GitHub release:
   - Jděte na GitHub → Releases → New Release
   - Tag: `v1.0.0`
   - Upload `VaciPlayer-1.0.0-darwin.tar.gz`

3. Vypočítejte SHA256:
   ```bash
   shasum -a 256 VaciPlayer-1.0.0-darwin.tar.gz
   ```

## Krok 2: Aktualizace Formula

1. Upravte `Formula/vacihacek-player.rb`:
   - Aktualizujte `version`
   - Vložte správný SHA256 hash
   - Změňte `YOUR_USERNAME` na své GitHub username

## Krok 3: Publikování

### Možnost A: Vlastní Homebrew Tap (doporučeno)

1. Vytvořte GitHub repo `homebrew-vacihacek`
2. Zkopírujte formula do `Casks/vacihacek-player.rb`
3. Uživatelé pak instalují:
   ```bash
   brew tap YOUR_USERNAME/vacihacek
   brew install --cask vacihacek-player
   ```

### Možnost B: Oficiální Homebrew Cask

1. Fork `homebrew/homebrew-cask`
2. Přidejte formula do `Casks/v/vacihacek-player.rb`
3. Vytvořte Pull Request

## Automatizace s GitHub Actions

Můžete vytvořit `.github/workflows/release.yml` pro automatické buildy při vytvoření tagu.

## Aktualizace

Při nové verzi:
1. Spusťte `./release.sh NEW_VERSION`
2. Vytvořte GitHub release
3. Aktualizujte formula (version + SHA256)
4. Push do homebrew tap repo