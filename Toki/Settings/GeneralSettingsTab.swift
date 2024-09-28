import ServiceManagement
import SwiftUI

// Local constants
private enum LocalConstants {
  static let defaultEndOfDayHour: Int = 4
  static let defaultEndOfDayMinute: Int = 0
  static let timeOptionCount: Int = 7
  static let pickerMaxWidth: CGFloat = 100
}

struct GeneralSettingsTab: View {
  @State private var showAppColors: Bool
  @State private var endOfDayTime: Date
  @State private var firstDayOfWeek: Int
  @State private var launchAtLogin: Bool
  @State private var showTimeUnderMinute: Bool

  enum ActiveDropdown: Hashable {
    case endOfDay
    case firstDayOfWeek
  }

  @State private var activeDropdown: ActiveDropdown?

  private let timeOptions: [Date]
  private let timeFormatter: DateFormatter
  private let weekdayOptions = Calendar.current.weekdaySymbols

  init() {
    let defaults = UserDefaults.standard
    _showAppColors = State(initialValue: defaults.bool(forKey: "showAppColors"))
    _launchAtLogin = State(initialValue: defaults.bool(forKey: "launchAtLogin"))
    _showTimeUnderMinute = State(
      initialValue: defaults.bool(
        forKey: "showTimeUnderMinute", defaultValue: true))

    let defaultEndOfDay =
      Calendar.current.date(
        from: DateComponents(
          hour: LocalConstants.defaultEndOfDayHour,
          minute: LocalConstants.defaultEndOfDayMinute)) ?? Date()
    _endOfDayTime = State(
      initialValue: defaults.object(forKey: "endOfDayTime") as? Date
        ?? defaultEndOfDay)

    _firstDayOfWeek = State(
      initialValue: defaults.integer(forKey: "firstDayOfWeek"))

    self.timeOptions = (0..<LocalConstants.timeOptionCount).map { hour in
      Calendar.current.date(from: DateComponents(hour: hour, minute: 0))
        ?? Date()
    }

    self.timeFormatter = DateFormatter()
    self.timeFormatter.dateFormat = "HH:mm"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {
      Text("General").font(.title).padding()

      SettingItem(
        title: "App Colors",
        description: "Show hashed app colors in the day timeline view.",
        icon: "swatchpalette"
      ) {
        Toggle("", isOn: appColorBinding)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
          .scaleEffect(0.8, anchor: .trailing)
      }

      ZStack {
        SettingItemGroup {
          VStack(alignment: .leading, spacing: Style.Layout.paddingSM) {
            ZStack {
              SettingItemRow(
                title: "End of Day",
                description:
                  "Set the time that starts a new day. Requires restart.",
                icon: "square.and.line.vertical.and.square.filled"
              ) { Spacer() }
            }
          }
        }.overlay(
          HStack {
            Spacer()
            UIDropdown(
              selectedOption: endOfDayBinding,
              options: timeOptions,
              optionToString: { self.timeFormatter.string(from: $0) },
              width: 150,
              height: Style.Button.heightSM,
              onClick: { self.activeDropdown = .endOfDay }
            )
            .padding(Style.Layout.paddingSM + 2)
            .allowsHitTesting(true)
          }
        )
      }
      .zIndex(self.activeDropdown == .endOfDay ? 99 : 0)

      ZStack {
        SettingItemGroup {
          VStack(alignment: .leading, spacing: Style.Layout.paddingSM) {
            ZStack {
              SettingItemRow(
                title: "First Day of Week",
                description:
                  "Set the first day of the week for the calendar views.",
                icon: "calendar"
              ) { Spacer() }
            }
          }
        }.overlay(
          HStack {
            Spacer()
            UIDropdown(
              selectedOption: firstDayOfWeekBinding,
              options: Array(1...7),
              optionToString: { Calendar.current.weekdaySymbols[$0 - 1] },
              width: 150,
              height: Style.Button.heightSM,
              onClick: { self.activeDropdown = .firstDayOfWeek }
            )
            .padding(Style.Layout.paddingSM + 2)
            .allowsHitTesting(true)
          }
        )
      }
      .zIndex(activeDropdown == .firstDayOfWeek ? 99 : 0)

      SettingItem(
        title: "Launch at Login",
        description: "Automatically start Toki when you log in.",
        icon: "power"
      ) {
        Toggle("", isOn: launchAtLoginBinding)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
          .scaleEffect(0.8, anchor: .trailing)
      }

      SettingItem(
        title: "Show Times Under Minute",
        description:
          "Display values under a minute. They will still be counted towards the total",
        icon: "clock"
      ) {
        Toggle("", isOn: showTimeUnderMinuteBinding)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
          .scaleEffect(0.8, anchor: .trailing)
      }

      Spacer()
      InfoBox {
        HStack {
          Image(systemName: "hand.raised.slash")
          Text("Toki is 100% private. No data ever leaves your device.")
            .foregroundStyle(.secondary)
          Spacer()
        }
      }
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

  private var endOfDayBinding: Binding<Date> {
    Binding(
      get: { self.endOfDayTime },
      set: {
        self.endOfDayTime = $0
        UserDefaults.standard.set($0, forKey: "endOfDayTime")
      }
    )
  }

  private var firstDayOfWeekBinding: Binding<Int> {
    Binding(
      get: { self.firstDayOfWeek },
      set: {
        self.firstDayOfWeek = $0
        UserDefaults.standard.set($0, forKey: "firstDayOfWeek")
        NotificationCenter.default.post(
          name: .firstDayOfWeekChanged, object: nil)
      }
    )
  }

  private var launchAtLoginBinding: Binding<Bool> {
    Binding(
      get: { self.launchAtLogin },
      set: {
        self.launchAtLogin = $0
        UserDefaults.standard.set($0, forKey: "launchAtLogin")
        self.setLaunchAtLogin($0)
      }
    )
  }

  private var showTimeUnderMinuteBinding: Binding<Bool> {
    Binding(
      get: { self.showTimeUnderMinute },
      set: {
        self.showTimeUnderMinute = $0
        UserDefaults.standard.set($0, forKey: "showTimeUnderMinute")
      }
    )
  }

  private func setLaunchAtLogin(_ enable: Bool) {
    if enable {
      try? SMAppService.mainApp.register()
    } else {
      try? SMAppService.mainApp.unregister()
    }
  }
}

extension UserDefaults {
  func bool(forKey key: String, defaultValue: Bool) -> Bool {
    if object(forKey: key) == nil {
      set(defaultValue, forKey: key)
    }
    return bool(forKey: key)
  }
}
