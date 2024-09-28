import SwiftUI

// Local constants
private enum LocalConstants {
  static let sidebarWidth: CGFloat = 200
}

struct SettingsWindow: View {
  private enum Tabs: Hashable {
    case general
    case appearance
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
    .frame(
      width: Constants.Settings.windowWidth,
      height: Constants.Settings.windowHeight
    )
    .background(VisualEffect().ignoresSafeArea())
    .padding(Style.Layout.padding)
  }

  var sidebar: some View {
    HStack {
      VStack(spacing: Style.Layout.paddingSM) {
        SettingsTabButton(
          title: "General",
          icon: "gear",
          isSelected: selectedTab == .general
        ) {
          selectedTab = .general
        }

        SettingsTabButton(
          title: "Appearance",
          icon: "paintbrush",
          isSelected: selectedTab == .appearance
        ) {
          selectedTab = .appearance
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
    case .appearance:
      AppearanceSettingsTab()
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
      UIButton(
        action: action,
        label: title,
        icon: icon,
        width: LocalConstants.sidebarWidth,
        height: Style.Button.heightSM,
        align: .leading
      )
    } else {
      UIButtonPlain(
        action: action,
        label: title,
        icon: icon,
        width: LocalConstants.sidebarWidth,
        height: Style.Button.heightSM,
        align: .leading
      )
    }
  }
}
