import SwiftUI

struct GeneralSettingsTab: View {
  @AppStorage("settings.general.name") private var name: String = ""
  @AppStorage("showAppColors") private var showAppColors: Bool = true

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      VStack {
        HStack {
          VStack(alignment: .leading) {
            Text("App Colors")
            Text("Show hashed app colors in the day timeline view.").font(
              .caption)
          }
          Spacer()
          Toggle(isOn: $showAppColors) {}
            .toggleStyle(SwitchToggleStyle(tint: .accentColor)).scaleEffect(
              0.8)
        }
      }
      .padding(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10).stroke(
          Color.secondary.opacity(0.2), lineWidth: 3)
      )
      .background(.ultraThickMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .padding(20)
  }
}
