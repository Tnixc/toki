import SwiftUI

struct MenuBarView: View {
  @EnvironmentObject private var menuBarModel: MenuBarModel

  var body: some View {
    VStack(spacing: 20) {
      Text("Hello, World!")
    }
    .frame(width: 200, height: 200)
  }
}
