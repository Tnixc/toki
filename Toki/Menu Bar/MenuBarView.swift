import SwiftUI

struct MenuBarView: View {
  @EnvironmentObject private var menuBarModel: MenuBarModel
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    VStack(spacing: 20) {
      InfoBox {
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Image(systemName: "clock")
            Text("Active Time:")
            Spacer()
            Text(menuBarModel.activeDuration)
          }
          HStack {
            Image(systemName: "arrow.right.to.line")
            Text("Clocked in:")
            Spacer()
            Text(
              menuBarModel.clockInTime?.formatted(
                date: .omitted, time: .shortened) ?? "N/A")
          }
          HStack {
            Image(systemName: "arrow.left.to.line")
            Text("Clocked out:")
            Spacer()
            Text(
              menuBarModel.clockOutTime?.formatted(
                date: .omitted, time: .shortened) ?? "N/A")
          }
        }
      }

      Button("Open Toki") {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: "main")
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .frame(width: 250)
    .background(VisualEffect().ignoresSafeArea())
  }
}
