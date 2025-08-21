import AppKit
import CoreGraphics

// Create app icon in multiple sizes for VaciPlayer
func createAppIconSet() {
    let sizes: [(String, CGFloat)] = [
        ("icon_16x16", 16),
        ("icon_16x16@2x", 32),
        ("icon_32x32", 32),
        ("icon_32x32@2x", 64),
        ("icon_128x128", 128),
        ("icon_128x128@2x", 256),
        ("icon_256x256", 256),
        ("icon_256x256@2x", 512),
        ("icon_512x512", 512),
        ("icon_512x512@2x", 1024)
    ]
    
    for (name, size) in sizes {
        createIconAtSize(name: name, size: size)
    }
    
    // Create Contents.json
    let contentsJson = """
    {
      "images" : [
        {
          "filename" : "icon_16x16.png",
          "idiom" : "mac",
          "scale" : "1x",
          "size" : "16x16"
        },
        {
          "filename" : "icon_16x16@2x.png",
          "idiom" : "mac",
          "scale" : "2x",
          "size" : "16x16"
        },
        {
          "filename" : "icon_32x32.png",
          "idiom" : "mac",
          "scale" : "1x",
          "size" : "32x32"
        },
        {
          "filename" : "icon_32x32@2x.png",
          "idiom" : "mac",
          "scale" : "2x",
          "size" : "32x32"
        },
        {
          "filename" : "icon_128x128.png",
          "idiom" : "mac",
          "scale" : "1x",
          "size" : "128x128"
        },
        {
          "filename" : "icon_128x128@2x.png",
          "idiom" : "mac",
          "scale" : "2x",
          "size" : "128x128"
        },
        {
          "filename" : "icon_256x256.png",
          "idiom" : "mac",
          "scale" : "1x",
          "size" : "256x256"
        },
        {
          "filename" : "icon_256x256@2x.png",
          "idiom" : "mac",
          "scale" : "2x",
          "size" : "256x256"
        },
        {
          "filename" : "icon_512x512.png",
          "idiom" : "mac",
          "scale" : "1x",
          "size" : "512x512"
        },
        {
          "filename" : "icon_512x512@2x.png",
          "idiom" : "mac",
          "scale" : "2x",
          "size" : "512x512"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    
    try! contentsJson.write(to: URL(fileURLWithPath: "/Users/janvaclavik/Sites/player/VaciPlayer.app/Contents/Resources/AppIcon.appiconset/Contents.json"), atomically: true, encoding: .utf8)
    
    print("App icon set created with all sizes")
}

func createIconAtSize(name: String, size: CGFloat) {
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    
    // Create bitmap context
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: Int(size), height: Int(size), 
                           bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, 
                           bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    // Background gradient (music theme - blue to purple)
    let gradient = CGGradient(colorsSpace: colorSpace, colors: [
        CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0), // Blue
        CGColor(red: 0.4, green: 0.2, blue: 0.7, alpha: 1.0)  // Purple
    ] as CFArray, locations: [0.0, 1.0])!
    
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), 
                              end: CGPoint(x: size, y: size), options: [])
    
    // Scale all elements based on size
    let scale = size / 1024.0
    
    // Draw guitar silhouette
    context.setFillColor(CGColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9))
    
    // Guitar body (oval)
    let guitarBodyRect = CGRect(x: size * 0.25, y: size * 0.35, 
                               width: size * 0.5, height: size * 0.4)
    context.fillEllipse(in: guitarBodyRect)
    
    // Guitar neck
    let neckRect = CGRect(x: size * 0.47, y: size * 0.15, 
                         width: size * 0.06, height: size * 0.25)
    context.fill(neckRect)
    
    // Guitar head
    let headRect = CGRect(x: size * 0.45, y: size * 0.1, 
                         width: size * 0.1, height: size * 0.08)
    context.fill(headRect)
    
    // Sound hole
    context.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8))
    let soundHoleRect = CGRect(x: size * 0.425, y: size * 0.5, 
                              width: size * 0.15, height: size * 0.15)
    context.fillEllipse(in: soundHoleRect)
    
    // Guitar strings (only if size is large enough)
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
    
    // Music notes overlay (only if size is large enough)
    if size >= 64 {
        context.setFillColor(CGColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.8))
        
        // Note 1
        let note1Center = CGPoint(x: size * 0.7, y: size * 0.3)
        let noteSize1 = 15 * scale
        context.fillEllipse(in: CGRect(x: note1Center.x - noteSize1, y: note1Center.y - noteSize1*0.7, width: noteSize1*2, height: noteSize1*1.4))
        context.fill(CGRect(x: note1Center.x + noteSize1*0.8, y: note1Center.y - noteSize1*2.7, width: 3 * scale, height: noteSize1*3.3))
        
        // Note 2
        let note2Center = CGPoint(x: size * 0.75, y: size * 0.45)
        let noteSize2 = 12 * scale
        context.fillEllipse(in: CGRect(x: note2Center.x - noteSize2, y: note2Center.y - noteSize2*0.7, width: noteSize2*2, height: noteSize2*1.3))
        context.fill(CGRect(x: note2Center.x + noteSize2*0.8, y: note2Center.y - noteSize2*2.9, width: 3 * scale, height: noteSize2*3.8))
    }
    
    // Play button overlay (triangle)
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))
    let playButtonCenter = CGPoint(x: size * 0.82, y: size * 0.8)
    let playSize: CGFloat = 25 * scale
    
    context.move(to: CGPoint(x: playButtonCenter.x - playSize/2, y: playButtonCenter.y - playSize/2))
    context.addLine(to: CGPoint(x: playButtonCenter.x + playSize/2, y: playButtonCenter.y))
    context.addLine(to: CGPoint(x: playButtonCenter.x - playSize/2, y: playButtonCenter.y + playSize/2))
    context.closePath()
    context.fillPath()
    
    // Create image and save
    let cgImage = context.makeImage()!
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
    
    // Save as PNG
    let imageRep = NSBitmapImageRep(data: nsImage.tiffRepresentation!)!
    let pngData = imageRep.representation(using: .png, properties: [:])!
    
    let filePath = "/Users/janvaclavik/Sites/player/VaciPlayer.app/Contents/Resources/AppIcon.appiconset/\(name).png"
    try! pngData.write(to: URL(fileURLWithPath: filePath))
}

createAppIconSet()