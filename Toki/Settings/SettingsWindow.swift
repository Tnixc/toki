import SwiftUI

struct SettingsWindow: View {
  private enum Tabs: Hashable {
    case general
  }

  var body: some View {
    TabView {
      GeneralSettingsTab()
        .tabItem {
          Label("General", systemImage: "gear")
        }
        .tag(Tabs.general)
    }
    .padding(20)
    .frame(width: 500, height: 450)
  }
}

struct SettingsWindow_Previews: PreviewProvider {
  static var previews: some View {
    SettingsWindow()
  }
}
