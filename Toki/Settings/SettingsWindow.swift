import SwiftUI

struct SettingsWindow: View {
  private enum Tabs: Hashable {
    case general
    case storage
    case export
    case clockOut
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
    .padding(10)
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

        SettingsTabButton(
          title: "Export",
          icon: "square.and.arrow.up",
          isSelected: selectedTab == .export
        ) {
          selectedTab = .export
        }
        SettingsTabButton(
          title: "Clock Out Reminders",
          icon: "clock.badge.exclamationmark",
          isSelected: selectedTab == .clockOut
        ) {
          selectedTab = .clockOut
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
      StorageSettingsTab()
    case .export:
      ExportSettingsTab()
    case .clockOut:
      ClockOutSettingsTab()
    }
  }
}

struct SettingsTabButton: View {
  let title: String
  let icon: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    if isSelected {
      CustomButton(
        action: action, label: title, icon: icon, width: 200, height: 36,
        align: .leading)
    } else {
      CustomButtonPlain(
        action: action, label: title, icon: icon, width: 200, height: 36,
        align: .leading)
    }
  }
}

struct SettingsWindow_Previews: PreviewProvider {
  static var previews: some View {
    SettingsWindow()
  }
}
