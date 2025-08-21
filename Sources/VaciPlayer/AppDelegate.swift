import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    
    override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from dock when there are no windows
        NSApplication.shared.setActivationPolicy(.regular)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @MainActor
    func openFolder() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = false
        panel.title = "Vyberte složku s hudbou"
        panel.prompt = "Vybrat"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // Post notification to trigger folder loading
                NotificationCenter.default.post(
                    name: .openFolderFromMenu, 
                    object: url
                )
            }
        }
    }
}

extension Notification.Name {
    static let openFolderFromMenu = Notification.Name("openFolderFromMenu")
    static let folderChanged = Notification.Name("folderChanged")
}