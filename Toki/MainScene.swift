import SwiftUI

struct MainScene: Scene {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 400, minHeight: 300)
        }
        .commands {
            SidebarCommands()
            ExportCommands()
            CommandGroup(replacing: .newItem) { }
        }

        Settings {
            SettingsWindow()
        }
    }
}
