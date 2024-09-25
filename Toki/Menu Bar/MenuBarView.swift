import SwiftUI

struct MenuBarView: View {
  @EnvironmentObject private var menuBarModel: MenuBarModel
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {

      VStack(alignment: .leading, spacing: Style.Layout.padding) {

        HStack {
          Image(systemName: "clock").font(.title)
            .padding(.trailing, Style.Layout.paddingSM)
          VStack(alignment: .leading) {
            Text("Active Time:").foregroundStyle(.secondary).font(.caption)
            Text(menuBarModel.activeDuration).font(.title2)
          }
          Spacer()
        }

        Divider()

        VStack(spacing: Style.Layout.paddingSM) {
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

      HStack(spacing: Style.Layout.padding) {
        CustomButton(
          action: {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "main")
          }, label: "Open Toki", height: Style.Button.heightSM
        )
        CustomButton(
          action: {
            NSApplication.shared.terminate(nil)
          },
          label: "Quit",
          icon: "xmark",
          height: Style.Button.heightSM
        )
      }
    }
    .padding(Style.Layout.padding)
    .background(VisualEffect().ignoresSafeArea())
  }
}
