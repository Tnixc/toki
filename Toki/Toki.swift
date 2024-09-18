import SwiftUI

@main
struct Toki: App {
  @StateObject private var menuBarModel = MenuBarModel()
  private let watcher = Watcher()

  init() {
    watcher.start()
  }

  var body: some Scene {
    MainScene()

    MenuBarExtra("Toki", systemImage: "hammer") {
      MenuBarView()
    }
    .menuBarExtraStyle(.window)
  }
}
