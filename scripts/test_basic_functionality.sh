#!/bin/bash

# Basic functionality tests for VaciPlayer
set -e

echo "🧪 Running basic functionality tests..."

# Test 1: Package validation
echo "📦 Testing Swift package validation..."
swift package dump-package > /dev/null
echo "✅ Package validation passed"

# Test 2: Debug build
echo "🔨 Testing debug build..."
swift build
echo "✅ Debug build passed"

# Test 3: Release build
echo "🚀 Testing release build..."
swift build --configuration release
echo "✅ Release build passed"

# Test 4: App bundle creation
echo "📱 Testing app bundle creation..."
chmod +x build_standalone_app.sh
./build_standalone_app.sh > /dev/null 2>&1
echo "✅ App bundle creation passed"

# Test 5: Verify app structure
echo "🏗️ Testing app bundle structure..."
test -d VaciPlayer.app || (echo "❌ VaciPlayer.app not found" && exit 1)
test -f VaciPlayer.app/Contents/MacOS/VaciPlayer || (echo "❌ Executable not found" && exit 1)
test -f VaciPlayer.app/Contents/Info.plist || (echo "❌ Info.plist not found" && exit 1)
test -d VaciPlayer.app/Contents/Resources/AppIcon.appiconset || (echo "❌ App icon set not found" && exit 1)
echo "✅ App bundle structure verified"

# Test 6: Info.plist validation
echo "📋 Testing Info.plist content..."
grep -q "VaciPlayer" VaciPlayer.app/Contents/Info.plist || (echo "❌ App name not found in Info.plist" && exit 1)
grep -q "14.0" VaciPlayer.app/Contents/Info.plist || (echo "❌ Minimum macOS version not set correctly" && exit 1)
grep -q "AppIcon" VaciPlayer.app/Contents/Info.plist || (echo "❌ App icon reference not found" && exit 1)
echo "✅ Info.plist validation passed"

# Test 7: Icon files validation
echo "🎨 Testing icon files..."
test -f VaciPlayer.app/Contents/Resources/AppIcon.appiconset/icon_512x512.png || (echo "❌ Main icon file not found" && exit 1)
test -f VaciPlayer.app/Contents/Resources/AppIcon.appiconset/Contents.json || (echo "❌ Icon metadata not found" && exit 1)
echo "✅ Icon files validation passed"

# Test 8: Code signing check (basic)
echo "🔐 Testing basic code structure..."
file VaciPlayer.app/Contents/MacOS/VaciPlayer | grep -q "Mach-O" || (echo "❌ Executable is not a valid Mach-O binary" && exit 1)
echo "✅ Binary structure validation passed"

echo ""
echo "🎉 All basic functionality tests passed!"
echo "✅ VaciPlayer is ready for distribution"