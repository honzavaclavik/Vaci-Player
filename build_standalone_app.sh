#!/bin/bash

echo "Building standalone VaciPlayer.app..."

# Clean previous builds
rm -rf VaciPlayer.app .build

# Create temporary Xcode project structure
mkdir -p TempProject/VaciPlayer

# Copy all Swift files to temp project
cp -r Sources/VaciPlayer/* TempProject/VaciPlayer/

# Create Info.plist
cat > TempProject/VaciPlayer/Info.plist << EOF
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

# Build using swiftc directly
echo "Compiling Swift files..."
swiftc -o TempProject/VaciPlayer/VaciPlayer \
    TempProject/VaciPlayer/*.swift \
    TempProject/VaciPlayer/*/*.swift \
    -framework SwiftUI \
    -framework AppKit \
    -framework AVFoundation \
    -target arm64-apple-macos14.0

if [ $? -eq 0 ]; then
    # Create app bundle
    mkdir -p VaciPlayer.app/Contents/MacOS
    mkdir -p VaciPlayer.app/Contents/Resources
    
    # Copy executable and Info.plist
    cp TempProject/VaciPlayer/VaciPlayer VaciPlayer.app/Contents/MacOS/
    cp TempProject/VaciPlayer/Info.plist VaciPlayer.app/Contents/
    
    echo "✅ VaciPlayer.app created successfully!"
    echo "You can now double-click VaciPlayer.app to launch without Terminal"
else
    echo "❌ Build failed"
fi

# Cleanup
rm -rf TempProject