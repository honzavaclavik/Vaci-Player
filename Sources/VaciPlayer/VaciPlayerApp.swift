import SwiftUI

@main
struct VaciPlayerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Otevřít složku...") {
                    AppDelegate.shared?.openFolder()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            
            CommandGroup(replacing: .appTermination) {
                Button("Quit VaciPlayer") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}