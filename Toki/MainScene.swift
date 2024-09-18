import SwiftUI

struct MainScene: Scene {
  var body: some Scene {
    WindowGroup {
      MainView()
        .frame(minWidth: 400, minHeight: 300)
        .toolbar {
          Text("Hello world").monospaced()
        }.background(.ultraThinMaterial)
    }
    .windowStyle(.hiddenTitleBar)
    .windowToolbarStyle(.unified(showsTitle: false))
    .commands {
      SidebarCommands()
      ExportCommands()
      CommandGroup(replacing: .newItem) {}
    }

    Settings {
      SettingsWindow()
    }
  }
}
