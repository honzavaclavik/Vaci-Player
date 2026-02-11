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
        guard let consumer = CGDataConsumer(data: pdfData) else { return false }
        var mediaBox = pageRect
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return false }
        
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
        
        // Ask user: save to Downloads or choose location
        let choiceAlert = NSAlert()
        choiceAlert.messageText = "Exportovat Playlist do PDF"
        choiceAlert.informativeText = "Kam chcete uložit soubor \"\(folderName)_playlist.pdf\"?"
        choiceAlert.addButton(withTitle: "Uložit do Stažené")
        choiceAlert.addButton(withTitle: "Vybrat umístění…")
        choiceAlert.addButton(withTitle: "Zrušit")

        let choice = choiceAlert.runModal()

        var targetURL: URL?

        if choice == .alertFirstButtonReturn {
            // Save to Downloads
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            targetURL = downloadsURL.appendingPathComponent("\(folderName)_playlist.pdf")
        } else if choice == .alertSecondButtonReturn {
            // Show save panel
            let savePanel = NSSavePanel()
            savePanel.title = "Exportovat Playlist do PDF"
            savePanel.nameFieldStringValue = "\(folderName)_playlist.pdf"
            savePanel.allowedContentTypes = [.pdf]

            if savePanel.runModal() == .OK {
                targetURL = savePanel.url
            }
        }

        guard let url = targetURL else { return false }

        do {
            try pdfData.write(to: url)

            // Show success alert with option to open
            let successAlert = NSAlert()
            successAlert.messageText = "Export dokončen"
            successAlert.informativeText = "Playlist byl uložen do:\n\(url.path)"
            successAlert.alertStyle = .informational
            successAlert.addButton(withTitle: "Otevřít PDF")
            successAlert.addButton(withTitle: "OK")

            if successAlert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(url)
            }

            return true
        } catch {
            let errorAlert = NSAlert()
            errorAlert.messageText = "Chyba při exportu"
            errorAlert.informativeText = "Nepodařilo se uložit PDF soubor: \(error.localizedDescription)"
            errorAlert.alertStyle = .critical
            errorAlert.addButton(withTitle: "OK")
            errorAlert.runModal()
            return false
        }
    }
}