import Foundation
import AppKit
import CoreGraphics
import CoreText

class PDFExportManager {
    static let shared = PDFExportManager()
    
    private init() {}
    
    func exportPlaylistToPDF(songs: [Song], folderName: String) -> Bool {
        let songsToExport = songs.filter { $0.includeInPDF }
        
        guard !songsToExport.isEmpty else {
            return false
        }
        
        // A4 size in points (72 points per inch, A4 is 8.27 × 11.69 inches)
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        
        // Create PDF data
        let pdfData = NSMutableData()
        let consumer = CGDataConsumer(data: pdfData)!
        var mediaBox = pageRect
        let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)!
        
        context.beginPDFPage(nil)
        
        // Set up fonts - larger sizes for better readability
        let titleFont = NSFont.boldSystemFont(ofSize: 32)
        
        // Calculate available space for songs first
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 80
        let leftMargin: CGFloat = 50
        let availableHeight = pageRect.height - topMargin - bottomMargin - 80 // space for title
        let songsCount = songsToExport.count
        
        // Calculate optimal font size based on number of songs
        let maxLineHeight = availableHeight / CGFloat(songsCount + 1) // +1 for spacing
        let adjustedFontSize = min(22, max(12, maxLineHeight - 4)) // Much larger fonts
        let adjustedSongFont = NSFont.boldSystemFont(ofSize: adjustedFontSize)
        
        // Set up attributes
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: NSColor.black
        ]
        
        let songAttributes: [NSAttributedString.Key: Any] = [
            .font: adjustedSongFont,
            .foregroundColor: NSColor.black
        ]
        
        // Create title
        let titleText = "Playlist - \(folderName)"
        let titleAttributedString = NSAttributedString(string: titleText, attributes: titleAttributes)
        let titleLine = CTLineCreateWithAttributedString(titleAttributedString)
        let titleSize = titleText.size(withAttributes: titleAttributes)
        let titleX = (pageRect.width - titleSize.width) / 2
        
        // Don't flip the coordinate system - draw directly
        context.textPosition = CGPoint(x: titleX, y: pageRect.height - topMargin)
        CTLineDraw(titleLine, context)
        
        // Draw songs
        var yPosition: CGFloat = pageRect.height - topMargin - 60 // Start below title
        for (index, song) in songsToExport.enumerated() {
            let songNumber = index + 1
            let songText = "\(songNumber). \(song.pdfDisplayTitle)"
            
            let songAttributedString = NSAttributedString(string: songText, attributes: songAttributes)
            let songLine = CTLineCreateWithAttributedString(songAttributedString)
            context.textPosition = CGPoint(x: leftMargin, y: yPosition)
            CTLineDraw(songLine, context)
            
            yPosition -= maxLineHeight
            
            // Stop if we run out of space
            if yPosition < bottomMargin {
                break
            }
        }
        context.endPDFPage()
        context.closePDF()
        
        // Show save panel
        let savePanel = NSSavePanel()
        savePanel.title = "Exportovat Playlist do PDF"
        savePanel.message = "Vyberte kam uložit PDF soubor s playlistem"
        savePanel.nameFieldStringValue = "\(folderName)_playlist.pdf"
        savePanel.allowedContentTypes = [.pdf]
        
        let response = savePanel.runModal()
        if response == .OK, let url = savePanel.url {
            do {
                try pdfData.write(to: url)
                
                // Show success alert
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Export dokončen"
                    alert.informativeText = "Playlist byl úspěšně exportován do PDF."
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                
                return true
            } catch {
                // Show error alert
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Chyba při exportu"
                    alert.informativeText = "Nepodařilo se uložit PDF soubor: \(error.localizedDescription)"
                    alert.alertStyle = .critical
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                return false
            }
        }
        
        return false
    }
}