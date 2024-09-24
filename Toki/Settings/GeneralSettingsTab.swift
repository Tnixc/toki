import SwiftUI

struct GeneralSettingsTab: View {
  @State private var showAppColors: Bool
  @State private var endOfDayTime: Date
  @State private var firstDayOfWeek: Int

  private let timeOptions: [Date]
  private let timeFormatter: DateFormatter
  private let weekdayOptions = Calendar.current.weekdaySymbols

  init() {
    let defaults = UserDefaults.standard
    _showAppColors = State(initialValue: defaults.bool(forKey: "showAppColors"))

    let defaultEndOfDay =
      Calendar.current.date(from: DateComponents(hour: 4, minute: 0)) ?? Date()
    _endOfDayTime = State(
      initialValue: defaults.object(forKey: "endOfDayTime") as? Date
        ?? defaultEndOfDay)

    _firstDayOfWeek = State(
      initialValue: defaults.integer(forKey: "firstDayOfWeek"))

    self.timeOptions = (0...6).map { hour in
      Calendar.current.date(from: DateComponents(hour: hour, minute: 0))
        ?? Date()
    }

    self.timeFormatter = DateFormatter()
    self.timeFormatter.dateFormat = "HH:mm"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("General").font(.title).padding()

      SettingItem(
        title: "App Colors",
        description: "Show hashed app colors in the day timeline view.",
        icon: "swatchpalette"
      ) {
        Toggle(
          "",
          isOn: Binding(
            get: { self.showAppColors },
            set: {
              self.showAppColors = $0
              UserDefaults.standard.set($0, forKey: "showAppColors")
            }
          )
        )
        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        .scaleEffect(0.8, anchor: .trailing)
      }

      SettingItem(
        title: "End of Day",
        description: "Set the time that starts a new day. Requires restart.",
        icon: "square.and.line.vertical.and.square.filled"
      ) {
        Picker(
          "",
          selection: Binding(
            get: { self.endOfDayTime },
            set: {
              self.endOfDayTime = $0
              UserDefaults.standard.set($0, forKey: "endOfDayTime")
            }
          )
        ) {
          ForEach(timeOptions, id: \.self) { date in
            Text(timeFormatter.string(from: date))
          }
        }
        .pickerStyle(.menu).frame(maxWidth: 100)
      }

      SettingItem(
        title: "First Day of Week",
        description: "Set the first day of the week for the calendar views.",
        icon: "calendar"
      ) {
        Picker(
          "",
          selection: Binding(
            get: { self.firstDayOfWeek },
            set: {
              self.firstDayOfWeek = $0
              UserDefaults.standard.set($0, forKey: "firstDayOfWeek")
              NotificationCenter.default.post(
                name: .firstDayOfWeekChanged, object: nil)
            }
          )
        ) {
          ForEach(1...7, id: \.self) { index in
            Text(Calendar.current.weekdaySymbols[index - 1]).tag(index)
          }
        }
        .pickerStyle(.menu).frame(maxWidth: 100)
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
}
