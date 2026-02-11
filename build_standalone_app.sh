#!/bin/bash

echo "Building standalone VaciPlayer.app..."

# Clean previous builds
rm -rf VaciPlayer.app .build

# Create temporary Xcode project structure
mkdir -p TempProject/VaciPlayer

# Copy all Swift files to temp project
cp -r Sources/VaciPlayer/* TempProject/VaciPlayer/

# Inject build date into BuildInfo.swift
BUILD_DATE=$(date '+%-d.%-m.%Y')
sed -i '' "s/__BUILD_DATE__/$BUILD_DATE/g" TempProject/VaciPlayer/Models/BuildInfo.swift

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
    <string>1.2</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2</string>
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

# Build using swiftc directly - Universal Binary (arm64 + x86_64)
echo "Compiling for arm64..."
swiftc -o TempProject/VaciPlayer/VaciPlayer-arm64 \
    TempProject/VaciPlayer/*.swift \
    TempProject/VaciPlayer/*/*.swift \
    -framework SwiftUI \
    -framework AppKit \
    -framework AVFoundation \
    -framework CoreGraphics \
    -framework CoreText \
    -target arm64-apple-macos14.0

if [ $? -ne 0 ]; then
    echo "❌ arm64 build failed"
    rm -rf TempProject
    exit 1
fi

echo "Compiling for x86_64..."
swiftc -o TempProject/VaciPlayer/VaciPlayer-x86_64 \
    TempProject/VaciPlayer/*.swift \
    TempProject/VaciPlayer/*/*.swift \
    -framework SwiftUI \
    -framework AppKit \
    -framework AVFoundation \
    -framework CoreGraphics \
    -framework CoreText \
    -target x86_64-apple-macos14.0

if [ $? -ne 0 ]; then
    echo "❌ x86_64 build failed"
    rm -rf TempProject
    exit 1
fi

echo "Creating Universal Binary..."
lipo -create \
    TempProject/VaciPlayer/VaciPlayer-arm64 \
    TempProject/VaciPlayer/VaciPlayer-x86_64 \
    -output TempProject/VaciPlayer/VaciPlayer

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
    
    # Generate AppIcon.icns
    echo "Generating app icons..."
    mkdir -p AppIcon.iconset
    
    # Create inline icon generator
    cat > temp_icon_generator.swift << 'ICON_EOF'
import AppKit
import CoreGraphics
import Foundation

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

    let s = size
    let cx = s / 2
    let cy = s / 2

    // --- macOS squircle background ---
    let inset = s * 0.03
    let cornerRadius = s * 0.22
    let bgRect = CGRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    context.addPath(bgPath)
    context.clip()

    // Deep dark gradient background
    let bgGrad = CGGradient(colorsSpace: colorSpace, colors: [
        CGColor(red: 0.05, green: 0.03, blue: 0.12, alpha: 1.0),
        CGColor(red: 0.10, green: 0.05, blue: 0.22, alpha: 1.0),
        CGColor(red: 0.04, green: 0.02, blue: 0.10, alpha: 1.0)
    ] as CFArray, locations: [0.0, 0.45, 1.0])!
    context.drawLinearGradient(bgGrad, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])

    // Warm radial glow behind the waveform area
    let warmGlow = CGGradient(colorsSpace: colorSpace, colors: [
        CGColor(red: 0.6, green: 0.2, blue: 0.5, alpha: 0.15),
        CGColor(red: 0.3, green: 0.1, blue: 0.4, alpha: 0.0)
    ] as CFArray, locations: [0.0, 1.0])!
    context.drawRadialGradient(warmGlow, startCenter: CGPoint(x: cx, y: cy * 0.85),
                               startRadius: 0, endCenter: CGPoint(x: cx, y: cy * 0.85),
                               endRadius: s * 0.55, options: [])

    // ============================================================
    // CIRCULAR SPECTRUM ANALYZER - main visual element
    // ============================================================
    let ringCenter = CGPoint(x: cx, y: cy + s * 0.02)
    let innerRadius = s * 0.18
    let barCount = size >= 128 ? 64 : (size >= 32 ? 32 : 16)
    let barGap = Double.pi * 2.0 / Double(barCount)
    let barAngularWidth = barGap * 0.65

    // Amplitudes - music-like pattern with crescendo
    let amps: [CGFloat] = [
        0.30, 0.45, 0.55, 0.70, 0.50, 0.80, 0.65, 0.90,
        0.75, 1.00, 0.85, 0.95, 0.70, 0.60, 0.85, 1.00,
        0.90, 0.75, 0.55, 0.80, 0.95, 0.65, 0.45, 0.70,
        0.85, 1.00, 0.60, 0.40, 0.55, 0.75, 0.90, 0.50,
        0.35, 0.50, 0.60, 0.75, 0.55, 0.85, 0.70, 0.95,
        0.80, 1.00, 0.90, 0.85, 0.65, 0.55, 0.80, 0.95,
        0.85, 0.70, 0.50, 0.75, 0.90, 0.60, 0.40, 0.65,
        0.80, 0.95, 0.55, 0.35, 0.50, 0.70, 0.85, 0.45
    ]

    let maxBarLength = s * 0.22

    // Draw glow layer first (behind bars)
    for i in 0..<barCount {
        let angle = Double(i) / Double(barCount) * 2.0 * Double.pi - Double.pi / 2.0
        let amp = amps[i % amps.count]
        let barLength = maxBarLength * amp

        let midR = innerRadius + barLength / 2
        let bx = ringCenter.x + midR * CGFloat(cos(angle))
        let by = ringCenter.y + midR * CGFloat(sin(angle))

        // Color: cyan -> magenta -> orange around the circle
        let t = CGFloat(i) / CGFloat(barCount)
        let r: CGFloat, g: CGFloat, b: CGFloat
        if t < 0.33 {
            let p = t / 0.33
            r = 0.0 + p * 0.9; g = 0.8 - p * 0.5; b = 1.0 - p * 0.3
        } else if t < 0.66 {
            let p = (t - 0.33) / 0.33
            r = 0.9 + p * 0.1; g = 0.3 - p * 0.1; b = 0.7 - p * 0.4
        } else {
            let p = (t - 0.66) / 0.34
            r = 1.0 - p * 1.0; g = 0.2 + p * 0.6; b = 0.3 + p * 0.7
        }

        // Soft glow
        let glowR = barLength * 0.4
        let glowGrad = CGGradient(colorsSpace: colorSpace, colors: [
            CGColor(red: r, green: g, blue: b, alpha: 0.25 * amp),
            CGColor(red: r, green: g, blue: b, alpha: 0.0)
        ] as CFArray, locations: [0.0, 1.0])!
        context.drawRadialGradient(glowGrad, startCenter: CGPoint(x: bx, y: by),
                                   startRadius: 0, endCenter: CGPoint(x: bx, y: by),
                                   endRadius: glowR, options: [])
    }

    // Draw actual bars
    for i in 0..<barCount {
        let angle = Double(i) / Double(barCount) * 2.0 * Double.pi - Double.pi / 2.0
        let amp = amps[i % amps.count]
        let barLength = maxBarLength * amp

        // Color
        let t = CGFloat(i) / CGFloat(barCount)
        let r: CGFloat, g: CGFloat, b: CGFloat
        if t < 0.33 {
            let p = t / 0.33
            r = 0.0 + p * 0.9; g = 0.8 - p * 0.5; b = 1.0 - p * 0.3
        } else if t < 0.66 {
            let p = (t - 0.33) / 0.33
            r = 0.9 + p * 0.1; g = 0.3 - p * 0.1; b = 0.7 - p * 0.4
        } else {
            let p = (t - 0.66) / 0.34
            r = 1.0 - p * 1.0; g = 0.2 + p * 0.6; b = 0.3 + p * 0.7
        }

        // Draw bar as arc segment
        let path = CGMutablePath()
        let startAngle = CGFloat(angle) - CGFloat(barAngularWidth) / 2
        let endAngle = CGFloat(angle) + CGFloat(barAngularWidth) / 2
        let outerR = innerRadius + barLength

        path.addArc(center: ringCenter, radius: innerRadius, startAngle: startAngle,
                    endAngle: endAngle, clockwise: false)
        path.addArc(center: ringCenter, radius: outerR, startAngle: endAngle,
                    endAngle: startAngle, clockwise: true)
        path.closeSubpath()

        context.setFillColor(CGColor(red: r, green: g, blue: b, alpha: 0.9))
        context.addPath(path)
        context.fillPath()
    }

    // ============================================================
    // CENTER - play button with frosted glass effect
    // ============================================================
    let centerRadius = s * 0.14

    // Dark frosted circle
    let centerGrad = CGGradient(colorsSpace: colorSpace, colors: [
        CGColor(red: 0.12, green: 0.08, blue: 0.20, alpha: 0.92),
        CGColor(red: 0.08, green: 0.05, blue: 0.15, alpha: 0.95)
    ] as CFArray, locations: [0.0, 1.0])!
    context.saveGState()
    context.addEllipse(in: CGRect(x: ringCenter.x - centerRadius, y: ringCenter.y - centerRadius,
                                   width: centerRadius * 2, height: centerRadius * 2))
    context.clip()
    context.drawRadialGradient(centerGrad, startCenter: ringCenter, startRadius: 0,
                               endCenter: ringCenter, endRadius: centerRadius, options: [])
    context.restoreGState()

    // Subtle ring around center
    context.setStrokeColor(CGColor(red: 0.5, green: 0.4, blue: 0.8, alpha: 0.3))
    context.setLineWidth(max(1.0, s * 0.003))
    context.addEllipse(in: CGRect(x: ringCenter.x - centerRadius, y: ringCenter.y - centerRadius,
                                   width: centerRadius * 2, height: centerRadius * 2))
    context.strokePath()

    // Play triangle in center
    let triH = centerRadius * 0.7
    let triW = triH * 0.9
    let triOffsetX = triW * 0.08 // visual centering nudge
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95))
    context.move(to: CGPoint(x: ringCenter.x - triW * 0.35 + triOffsetX, y: ringCenter.y + triH * 0.5))
    context.addLine(to: CGPoint(x: ringCenter.x + triW * 0.65 + triOffsetX, y: ringCenter.y))
    context.addLine(to: CGPoint(x: ringCenter.x - triW * 0.35 + triOffsetX, y: ringCenter.y - triH * 0.5))
    context.closePath()
    context.fillPath()

    // ============================================================
    // Edge highlight on squircle
    // ============================================================
    context.resetClip()
    context.addPath(bgPath)
    context.clip()
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.06))
    context.setLineWidth(max(1.0, s * 0.003))
    context.addPath(bgPath)
    context.strokePath()

    // --- Save ---
    let cgImage = context.makeImage()!
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
    let imageRep = NSBitmapImageRep(data: nsImage.tiffRepresentation!)!
    let pngData = imageRep.representation(using: .png, properties: [:])!

    try! pngData.write(to: URL(fileURLWithPath: "AppIcon.iconset/\(name).png"))
}

for (name, size) in sizes { createIconAtSize(name: name, size: size) }

ICON_EOF

    # Generate icon PNGs
    swift temp_icon_generator.swift > /dev/null 2>&1
    rm temp_icon_generator.swift

    # Convert iconset to icns
    iconutil -c icns AppIcon.iconset -o VaciPlayer.app/Contents/Resources/AppIcon.icns
    rm -rf AppIcon.iconset
    echo "Generated AppIcon.icns"
    
    # Sign the application (ad-hoc signing for local development)
    echo "Signing application..."
    codesign --force --deep --sign - VaciPlayer.app
    
    if [ $? -eq 0 ]; then
        echo "✅ VaciPlayer.app created and signed successfully!"
        echo "You can now double-click VaciPlayer.app to launch without Terminal"
    else
        echo "⚠️  VaciPlayer.app created but signing failed"
        echo "You may need to remove quarantine: sudo xattr -rd com.apple.quarantine VaciPlayer.app"
    fi
else
    echo "❌ Build failed"
fi

# Cleanup
rm -rf TempProject