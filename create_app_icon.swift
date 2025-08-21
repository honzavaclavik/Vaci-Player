import AppKit
import CoreGraphics

// Create app icon for VaciPlayer
func createAppIcon() {
    let iconSize: CGFloat = 1024 // High resolution for all sizes
    let rect = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
    
    // Create bitmap context
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: Int(iconSize), height: Int(iconSize), 
                           bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, 
                           bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    // Background gradient (music theme - blue to purple)
    let gradient = CGGradient(colorsSpace: colorSpace, colors: [
        CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0), // Blue
        CGColor(red: 0.4, green: 0.2, blue: 0.7, alpha: 1.0)  // Purple
    ] as CFArray, locations: [0.0, 1.0])!
    
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), 
                              end: CGPoint(x: iconSize, y: iconSize), options: [])
    
    // Draw guitar silhouette
    context.setFillColor(CGColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9))
    
    // Guitar body (oval)
    let guitarBodyRect = CGRect(x: iconSize * 0.25, y: iconSize * 0.35, 
                               width: iconSize * 0.5, height: iconSize * 0.4)
    context.fillEllipse(in: guitarBodyRect)
    
    // Guitar neck
    let neckRect = CGRect(x: iconSize * 0.47, y: iconSize * 0.15, 
                         width: iconSize * 0.06, height: iconSize * 0.25)
    context.fill(neckRect)
    
    // Guitar head
    let headRect = CGRect(x: iconSize * 0.45, y: iconSize * 0.1, 
                         width: iconSize * 0.1, height: iconSize * 0.08)
    context.fill(headRect)
    
    // Sound hole
    context.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8))
    let soundHoleRect = CGRect(x: iconSize * 0.425, y: iconSize * 0.5, 
                              width: iconSize * 0.15, height: iconSize * 0.15)
    context.fillEllipse(in: soundHoleRect)
    
    // Guitar strings
    context.setStrokeColor(CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.9))
    context.setLineWidth(2.0)
    
    for i in 0..<6 {
        let stringX = iconSize * (0.42 + Double(i) * 0.026)
        context.move(to: CGPoint(x: stringX, y: iconSize * 0.15))
        context.addLine(to: CGPoint(x: stringX, y: iconSize * 0.75))
        context.strokePath()
    }
    
    // Music notes overlay
    context.setFillColor(CGColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.8))
    
    // Note 1
    let note1Center = CGPoint(x: iconSize * 0.7, y: iconSize * 0.3)
    context.fillEllipse(in: CGRect(x: note1Center.x - 15, y: note1Center.y - 10, width: 30, height: 20))
    context.fill(CGRect(x: note1Center.x + 12, y: note1Center.y - 40, width: 3, height: 50))
    
    // Note 2
    let note2Center = CGPoint(x: iconSize * 0.75, y: iconSize * 0.45)
    context.fillEllipse(in: CGRect(x: note2Center.x - 12, y: note2Center.y - 8, width: 24, height: 16))
    context.fill(CGRect(x: note2Center.x + 10, y: note2Center.y - 35, width: 3, height: 45))
    
    // Play button overlay (triangle)
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9))
    let playButtonCenter = CGPoint(x: iconSize * 0.82, y: iconSize * 0.8)
    let playSize: CGFloat = 25
    
    context.move(to: CGPoint(x: playButtonCenter.x - playSize/2, y: playButtonCenter.y - playSize/2))
    context.addLine(to: CGPoint(x: playButtonCenter.x + playSize/2, y: playButtonCenter.y))
    context.addLine(to: CGPoint(x: playButtonCenter.x - playSize/2, y: playButtonCenter.y + playSize/2))
    context.closePath()
    context.fillPath()
    
    // Create image and save
    let cgImage = context.makeImage()!
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: iconSize, height: iconSize))
    
    // Save as PNG
    let imageRep = NSBitmapImageRep(data: nsImage.tiffRepresentation!)!
    let pngData = imageRep.representation(using: .png, properties: [:])!
    
    try! pngData.write(to: URL(fileURLWithPath: "/Users/janvaclavik/Sites/player/AppIcon.png"))
    print("App icon created: AppIcon.png")
}

createAppIcon()