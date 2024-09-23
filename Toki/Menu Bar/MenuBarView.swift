import SwiftUI

struct MenuBarView: View {
  @EnvironmentObject private var menuBarModel: MenuBarModel
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {

      VStack(alignment: .leading, spacing: 10) {

        HStack {
          Image(systemName: "clock").font(.title)
            .padding(.trailing, 4)
          VStack(alignment: .leading) {
            Text("Active Time:").foregroundStyle(.secondary).font(.caption)
            Text(menuBarModel.activeDuration).font(.title2)
          }
          Spacer()
        }

        Divider()

        VStack(spacing: 6) {
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

      Divider()

      HStack(spacing: 10) {
        CustomButton(
          action: {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "main")
          }, label: "Open Toki", height: 30
        )
        CustomButton(
          action: {
            NSApplication.shared.terminate(nil)
          },
          label: "Quit",
          icon: "xmark",
          height: 30
        )
      }
    }
    .padding()
    .background(VisualEffect().ignoresSafeArea())
  }
}
