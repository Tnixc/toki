import SettingsAccess
import SwiftUI

struct MainScene: Scene {
  var body: some Scene {
    Window("Toki", id: "main") {
      MainView()
        .openSettingsAccess()
        .frame(
          minWidth: 400,
          maxWidth: .infinity,
          minHeight: 500,
          maxHeight: .infinity
        )
        .padding(.top, 1)
        .padding(.horizontal)
        .toolbar { Text("Toki").fontWeight(.bold) }

        .background(VisualEffect().ignoresSafeArea())
    }
    .defaultSize(width: 800, height: 600)
    .windowStyle(.hiddenTitleBar)
    .windowToolbarStyle(.unified(showsTitle: false))

    .commands {
      CommandGroup(replacing: .newItem) {}
    }

    Settings {
      SettingsWindow()
        .background(VisualEffect().ignoresSafeArea())
    }
    .windowStyle(.hiddenTitleBar)
    .windowToolbarStyle(.automatic)
  }
}

struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView {
    return NSVisualEffectView()
  }
  func updateNSView(_ nsView: NSView, context: Context) {}
}
