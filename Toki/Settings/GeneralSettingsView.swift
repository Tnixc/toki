import SwiftUI

struct GeneralSettingsTab: View {
  @AppStorage("settings.general.name") private var name: String = ""
  @AppStorage("showAppColors") private var showAppColors: Bool = true

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Toggle("Show App Colors", isOn: $showAppColors)

      Divider()

      Text("Other settings can be added here")
    }
    .padding(20)
    .frame(width: 300)
  }
}
