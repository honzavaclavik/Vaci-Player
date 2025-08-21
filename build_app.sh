#!/bin/bash

# Build script for creating macOS app bundle

echo "Building VaciPlayer.app..."

# Build the executable
swift build -c release

# Create app bundle structure
mkdir -p VaciPlayer.app/Contents/MacOS
mkdir -p VaciPlayer.app/Contents/Resources

# Copy executable
cp .build/release/VaciPlayer VaciPlayer.app/Contents/MacOS/

# Create Info.plist
cat > VaciPlayer.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>VaciPlayer</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.vacihacek.player</string>
    <key>CFBundleName</key>
    <string>VaciPlayer</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.music</string>
</dict>
</plist>
EOF

echo "VaciPlayer.app created successfully!"
echo "You can now double-click VaciPlayer.app to launch the application"
