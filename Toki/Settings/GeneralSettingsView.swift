import SwiftUI

struct GeneralSettingsTab: View {

  @AppStorage("settings.general.name") private var name: String = ""

  var body: some View {
    VStack {
      Text("Hello from settings")
    }
    .padding(20)
  }
}

struct GeneralSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    GeneralSettingsTab()
  }
}
