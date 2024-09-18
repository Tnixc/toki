import SwiftUI

@main
struct Toki: App {
  @StateObject private var menuBarModel = MenuBarModel()

  var body: some Scene {
    MainScene()

    MenuBarExtra("Toki", systemImage: "hammer") {
      MenuBarView()
    }
    .menuBarExtraStyle(.window)

  }
}
