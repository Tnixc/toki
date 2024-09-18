import SwiftUI

struct MainScene: Scene {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 400, minHeight: 300)
        }
        .commands {
            AboutCommand()
            SidebarCommands()
            ExportCommands()
            AlwaysOnTopCommand()
            MyCommands()
            CommandGroup(replacing: .newItem) { }
        }

        Settings {
            SettingsWindow()
        }
    }
}
