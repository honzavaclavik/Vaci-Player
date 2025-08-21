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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
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
    -framework CoreGraphics \
    -framework CoreText \
    -target arm64-apple-macos14.0

if [ $? -eq 0 ]; then
    # Create app bundle
    mkdir -p VaciPlayer.app/Contents/MacOS
    mkdir -p VaciPlayer.app/Contents/Resources
    
    # Copy executable and Info.plist
    cp TempProject/VaciPlayer/VaciPlayer VaciPlayer.app/Contents/MacOS/
    cp TempProject/VaciPlayer/Info.plist VaciPlayer.app/Contents/
    
    # Copy icon if it exists
    if [ -f AppIcon.png ]; then
        cp AppIcon.png VaciPlayer.app/Contents/Resources/
    fi
    
    # Generate AppIcon.appiconset
    echo "Generating app icons..."
    mkdir -p VaciPlayer.app/Contents/Resources/AppIcon.appiconset
    
    # Create inline icon generator
    cat > temp_icon_generator.swift << 'ICON_EOF'
import AppKit
import CoreGraphics

let sizes: [(String, CGFloat)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32), ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256), ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024)
]

func createIconAtSize(name: String, size: CGFloat) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: Int(size), height: Int(size), 
                           bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, 
                           bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    let gradient = CGGradient(colorsSpace: colorSpace, colors: [
        CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
        CGColor(red: 0.4, green: 0.2, blue: 0.7, alpha: 1.0)
    ] as CFArray, locations: [0.0, 1.0])!
    
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), 
                              end: CGPoint(x: size, y: size), options: [])
    
    let scale = size / 1024.0
    context.setFillColor(CGColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9))
    context.fillEllipse(in: CGRect(x: size * 0.25, y: size * 0.35, width: size * 0.5, height: size * 0.4))
    context.fill(CGRect(x: size * 0.47, y: size * 0.15, width: size * 0.06, height: size * 0.25))
    context.fill(CGRect(x: size * 0.45, y: size * 0.1, width: size * 0.1, height: size * 0.08))
    
    context.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8))
    context.fillEllipse(in: CGRect(x: size * 0.425, y: size * 0.5, width: size * 0.15, height: size * 0.15))
    
    if size >= 32 {
        context.setStrokeColor(CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.9))
        context.setLineWidth(max(1.0, 2.0 * scale))
        for i in 0..<6 {
            let stringX = size * (0.42 + Double(i) * 0.026)
            context.move(to: CGPoint(x: stringX, y: size * 0.15))
            context.addLine(to: CGPoint(x: stringX, y: size * 0.75))
            context.strokePath()
        }
    }
    
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))
    let playSize: CGFloat = 25 * scale
    let playCenter = CGPoint(x: size * 0.82, y: size * 0.8)
    context.move(to: CGPoint(x: playCenter.x - playSize/2, y: playCenter.y - playSize/2))
    context.addLine(to: CGPoint(x: playCenter.x + playSize/2, y: playCenter.y))
    context.addLine(to: CGPoint(x: playCenter.x - playSize/2, y: playCenter.y + playSize/2))
    context.closePath()
    context.fillPath()
    
    let cgImage = context.makeImage()!
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
    let imageRep = NSBitmapImageRep(data: nsImage.tiffRepresentation!)!
    let pngData = imageRep.representation(using: .png, properties: [:])!
    
    try! pngData.write(to: URL(fileURLWithPath: "VaciPlayer.app/Contents/Resources/AppIcon.appiconset/\(name).png"))
}

for (name, size) in sizes { createIconAtSize(name: name, size: size) }

let contentsJson = """
{"images":[
{"filename":"icon_16x16.png","idiom":"mac","scale":"1x","size":"16x16"},
{"filename":"icon_16x16@2x.png","idiom":"mac","scale":"2x","size":"16x16"},
{"filename":"icon_32x32.png","idiom":"mac","scale":"1x","size":"32x32"},
{"filename":"icon_32x32@2x.png","idiom":"mac","scale":"2x","size":"32x32"},
{"filename":"icon_128x128.png","idiom":"mac","scale":"1x","size":"128x128"},
{"filename":"icon_128x128@2x.png","idiom":"mac","scale":"2x","size":"128x128"},
{"filename":"icon_256x256.png","idiom":"mac","scale":"1x","size":"256x256"},
{"filename":"icon_256x256@2x.png","idiom":"mac","scale":"2x","size":"256x256"},
{"filename":"icon_512x512.png","idiom":"mac","scale":"1x","size":"512x512"},
{"filename":"icon_512x512@2x.png","idiom":"mac","scale":"2x","size":"512x512"}
],"info":{"author":"xcode","version":1}}
"""
try! contentsJson.write(to: URL(fileURLWithPath: "VaciPlayer.app/Contents/Resources/AppIcon.appiconset/Contents.json"), atomically: true, encoding: .utf8)
ICON_EOF
    
    # Generate icons
    swift temp_icon_generator.swift > /dev/null 2>&1
    rm temp_icon_generator.swift
    echo "Generated AppIcon.appiconset"
    
    echo "✅ VaciPlayer.app created successfully!"
    echo "You can now double-click VaciPlayer.app to launch without Terminal"
else
    echo "❌ Build failed"
fi

# Cleanup
rm -rf TempProject