import SwiftUI

struct AppearanceSettingsTab: View {
  @AppStorage("selectedAppearance") private var selectedAppearance: Appearance =
    .system
  @Environment(\.colorScheme) var colorScheme

  @State var showAppColors: Bool
  @State var useOpacity: Bool

  init() {
    let defaults = UserDefaults.standard
    _showAppColors = State(initialValue: defaults.bool(forKey: "showAppColors"))
    _useOpacity = State(initialValue: defaults.bool(forKey: "useOpacity"))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {
      Text("Appearance").font(.title).padding()

      SettingItem(
        title: "App Colors",
        description: "Show hashed app colors in the day timeline view.",
        icon: "swatchpalette"
      ) {
        Toggle("", isOn: appColorBinding)
          .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
          .scaleEffect(0.8, anchor: .trailing)
      }

      SettingItem(
        title: "Use Opacity",
        description: "Vary opacity for each segment depending on usage.",
        icon: "rectangle.leadinghalf.filled"
      ) {
        Toggle("", isOn: useOpacityBinding)
          .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
          .scaleEffect(0.8, anchor: .trailing)
      }

      ZStack {
        SettingItemGroup {
          VStack(alignment: .leading, spacing: Style.Layout.paddingSM) {
            ZStack {
              SettingItemRow(
                title: "App Theme",
                description: "Choose the appearance of the app",
                icon: "paintbrush"
              ) { Spacer() }
            }
          }
        }.overlay(
          HStack {
            Spacer()
            UIDropdown(
              selectedOption: $selectedAppearance,
              options: Appearance.allCases,
              optionToString: { $0.description },
              width: 150,
              height: Style.Button.heightSM,
              onSelect: { _ in updateAppAppearance() }
            )
            .allowsHitTesting(true)
          }
          .padding(Style.Layout.paddingSM + 2)
        )
      }
      Spacer()
    }
  }

  private var appColorBinding: Binding<Bool> {
    Binding(
      get: { self.showAppColors },
      set: {
        self.showAppColors = $0
        UserDefaults.standard.set($0, forKey: "showAppColors")
      }
    )
  }

  private var useOpacityBinding: Binding<Bool> {
    Binding(
      get: { self.useOpacity },
      set: {
        self.useOpacity = $0
        UserDefaults.standard.set($0, forKey: "useOpacity")
      }
    )
  }

  public func updateAppAppearance() {
    switch selectedAppearance {
    case .light:
      NSApp.appearance = NSAppearance(named: .aqua)
    case .dark:
      NSApp.appearance = NSAppearance(named: .darkAqua)
    case .system:
      NSApp.appearance = nil
    }
  }
}

enum Appearance: String, CaseIterable {
  case light
  case dark
  case system

  var description: String {
    switch self {
    case .light: return "Light"
    case .dark: return "Dark"
    case .system: return "System"
    }
  }
}
