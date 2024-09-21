import SwiftUI

struct GeneralSettingsTab: View {
  @State private var showAppColors: Bool
  @State private var endOfDayTime: Date

  private let timeOptions: [Date]
  private let timeFormatter: DateFormatter

  init() {
    let defaults = UserDefaults.standard
    _showAppColors = State(initialValue: defaults.bool(forKey: "showAppColors"))

    let defaultEndOfDay =
      Calendar.current.date(from: DateComponents(hour: 4, minute: 0)) ?? Date()
    _endOfDayTime = State(
      initialValue: defaults.object(forKey: "endOfDayTime") as? Date
        ?? defaultEndOfDay)

    self.timeOptions = (0...6).flatMap { hour in
      [0].map { minute in
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute))
          ?? Date()
      }
    }

    self.timeFormatter = DateFormatter()
    self.timeFormatter.dateFormat = "h:mm a"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      SettingItem(
        title: "App Colors",
        description: "Show hashed app colors in the day timeline view."
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
        .scaleEffect(0.8)
      }

      SettingItem(
        title: "End of Day",
        description: "Set the time that separates work days."
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
        .pickerStyle(MenuPickerStyle())
      }
    }
    .padding(20)
  }
}

struct SettingItem<Content: View>: View {
  let title: String
  let description: String
  let content: () -> Content

  var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading) {
          Text(title)
          Text(description).font(.caption)
        }
        Spacer()
        content()
      }
    }
    .padding(10)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
    )
    .background(Color.secondary.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
