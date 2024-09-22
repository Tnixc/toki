import SwiftUI

struct SettingsWindow: View {
  private enum Tabs: Hashable {
    case general
    case storage
  }

  @State private var selectedTab: Tabs = .general

  var body: some View {
    HStack {
      sidebar
      Spacer()
      tabContent
      Spacer()
    }
    .frame(width: 600, height: 400)
    .background(VisualEffect().ignoresSafeArea())
    .padding()
  }

  var sidebar: some View {
    HStack {
      VStack(spacing: 6) {
        SettingsTabButton(
          title: "General",
          icon: "gear",
          isSelected: selectedTab == .general
        ) {
          selectedTab = .general
        }

        SettingsTabButton(
          title: "Storage",
          icon: "internaldrive",
          isSelected: selectedTab == .storage
        ) {
          selectedTab = .storage
        }

        Spacer()
      }
      Divider()
    }
  }

  @ViewBuilder
  var tabContent: some View {
    switch selectedTab {
    case .general:
      GeneralSettingsTab()
    case .storage:
      Text("Storage Settings")  // Placeholder for Storage settings
    }
  }
}

struct SettingsTabButton: View {
  let title: String
  let icon: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    CustomButton(
      action: action, label: title, icon: icon, width: 160, height: 36,
      align: .leading)
  }
}

//  .background(isSelected ? Color.accentColor : Color.clear)
struct SettingsWindow_Previews: PreviewProvider {
  static var previews: some View {
    SettingsWindow()
  }
}
