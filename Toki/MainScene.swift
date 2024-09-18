import SwiftUI

struct MainScene: Scene {
  var body: some Scene {
    WindowGroup {
      MainView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
          Text("Hello world").monospaced()
        }
        .background(VisualEffect().ignoresSafeArea())
    }
    .defaultSize(width: 800, height: 600)
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
struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) {}
}
