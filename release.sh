#!/bin/bash

VERSION=${1:-1.0.0}
echo "Creating release for version $VERSION"

# Build the app
echo "Building VaciPlayer.app..."
./build_standalone_app.sh

if [ ! -d "VaciPlayer.app" ]; then
    echo "❌ Build failed"
    exit 1
fi

# Create tar.gz archive
echo "Creating archive..."
tar -czf "VaciPlayer-${VERSION}-darwin.tar.gz" VaciPlayer.app

echo "✅ Release archive created: VaciPlayer-${VERSION}-darwin.tar.gz"
echo ""
echo "Next steps:"
echo "1. Create GitHub release with tag v${VERSION}"
echo "2. Upload VaciPlayer-${VERSION}-darwin.tar.gz as release asset"
echo "3. Calculate SHA256: shasum -a 256 VaciPlayer-${VERSION}-darwin.tar.gz"