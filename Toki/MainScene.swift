import SettingsAccess
import SwiftUI

struct MainScene: Scene {
  var body: some Scene {
    Window("Toki", id: "main") {
      MainView()
        .frame(
          minWidth: 400,
          maxWidth: .infinity,
          minHeight: 500,
          maxHeight: .infinity
        )
        .padding(.top, 1)
        .padding(.horizontal)
        .toolbar { Text("Toki").fontWeight(.semibold) }
        .background(VisualEffect().ignoresSafeArea())
    }
    .defaultSize(width: 800, height: 600)
    .windowStyle(.hiddenTitleBar)
    .windowToolbarStyle(.unified(showsTitle: false))

    .commands {
      CommandGroup(replacing: .newItem) {}
    }

    Window("Toki Settings", id: "settings") {
      SettingsWindow()
        .background(VisualEffect().ignoresSafeArea())
        .frame(
          minWidth: Constants.Settings.windowWidth,
          minHeight: Constants.Settings.windowHeight
        )
        .toolbar { Text("Toki Settings").fontWeight(.semibold) }
    }
    .windowResizability(WindowResizability.contentSize)
    .defaultSize(
      width: Constants.Settings.windowWidth,
      height: Constants.Settings.windowHeight
    )
    .windowStyle(.hiddenTitleBar)
    .windowToolbarStyle(.unified(showsTitle: true))
  }
}

struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView {
    let visualEffectView = NSVisualEffectView()
    visualEffectView.state = NSVisualEffectView.State.active
    visualEffectView.isEmphasized = true
    return visualEffectView
  }
  func updateNSView(_ nsView: NSView, context: Context) {}
}
