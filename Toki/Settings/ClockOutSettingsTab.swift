import SwiftUI

struct ClockOutSettingsTab: View {
  @State private var clockOutTime: Date
  @State private var clockOutEnabled: Bool
  @State private var clockOutReminderEnabled: Bool
  @State private var clockOutReminderInterval: Int
  @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
  @State private var clockOutUseOverlay: Bool = false

  private let reminderIntervals = [1, 3, 5, 10, 15, 20, 30, 60, 120]
  private let defaults = UserDefaults.standard

  init() {
    let defaultClockOutTime =
      Calendar.current.date(
        from: DateComponents(
          hour: Constants.defaultClockOutHour,
          minute: Constants.defaultClockOutMinute)) ?? Date()
    _clockOutTime = State(
      initialValue: defaults.object(forKey: "clockOutTime") as? Date
        ?? defaultClockOutTime)
    _clockOutEnabled = State(
      initialValue: defaults.bool(forKey: "clockOutEnabled"))
    _clockOutReminderEnabled = State(
      initialValue: defaults.bool(forKey: "clockOutReminderEnabled"))
    _clockOutReminderInterval = State(
      initialValue: defaults.integer(forKey: "clockOutReminderInterval"))
    _clockOutUseOverlay = State(
      initialValue: defaults.bool(forKey: "clockOutUseOverlay"))

    if defaults.object(forKey: "clockOutReminderInterval") == nil {
      defaults.set(
        Constants.defaultReminderInterval, forKey: "clockOutReminderInterval")
    }

    if let savedDays = defaults.object(forKey: "clockOutSelectedDays") as? [Int] {
      _selectedDays = State(initialValue: Set(savedDays))
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Style.Layout.padding) {
        Text("Clock Out").font(.title).padding()

        VStack(alignment: .leading, spacing: Style.Layout.padding) {
          SettingItemGroup {
            VStack(alignment: .leading, spacing: Style.Layout.paddingSM) {
              SettingItemRow(
                title: "Enable Clock Out",
                description: "Turn on/off clock out notifications",
                icon: "bell.badge"
              ) {
                Toggle("", isOn: $clockOutEnabled)
                  .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                  .scaleEffect(0.8, anchor: .topTrailing)
                  .onChange(of: clockOutEnabled) {
                    defaults.set(clockOutEnabled, forKey: "clockOutEnabled")
                    Notifier.shared.updateSettings()
                  }
              }

              Divider()

              SettingItemRow(
                title: "Clock Out Time",
                description:
                  "Set the time you want to be reminded to clock out.",
                icon: "clock.arrow.circlepath"
              ) {
                DatePicker(
                  "", selection: $clockOutTime,
                  displayedComponents: .hourAndMinute
                )
                .labelsHidden()
                .disabled(!clockOutEnabled)
                .onChange(of: clockOutTime) {
                  defaults.set(clockOutTime, forKey: "clockOutTime")
                  Notifier.shared.updateSettings()
                }
              }

              Divider()

              SettingItemRow(
                title: "Enable overlay",
                description: "Use a blurred overlay to remind you to clock out",
                icon: "circle.rectangle.filled.pattern.diagonalline"
              ) {
                Toggle("", isOn: $clockOutUseOverlay)
                  .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                  .scaleEffect(0.8, anchor: .trailing)
                  .onChange(of: clockOutUseOverlay) {
                    defaults.set(
                      clockOutUseOverlay, forKey: "clockOutUseOverlay")
                    Notifier.shared.updateSettings()
                  }
              }

              HStack {
                Spacer()
                UIButton(
                  action: {
                    Notifier.shared.showOverlay(
                      title: "This is a demo overlay",
                      message: "It's more effective than a notification",
                      dismissAfter: Constants.overlayDismissTime)
                  }, label: "Show overlay", icon: "circle.dotted",
                  height: Style.Button.heightSM)
              }

              Divider()

              SettingItemRow(
                title: "Active Days",
                description: "Select the days for clock out reminders.",
                icon: "calendar"
              ) { Spacer() }
              HStack {
                Spacer()
                ForEach(0..<7) { index in
                  let day = Calendar.current.weekdaySymbols[index]
                  let dayName = day.prefix(3).capitalized
                  DayToggleButton(
                    day: dayName,
                    isSelected: selectedDays.contains(index + 1)
                  ) {
                    toggleDay(index + 1)
                  }
                }
              }
            }
          }

          SettingItemGroup {
            VStack(alignment: .leading, spacing: Style.Layout.paddingSM) {
              SettingItemRow(
                title: "Enable Persistent Reminders",
                description:
                  "Turn on/off clock out persistent reminder notifications",
                icon: "bell.and.waves.left.and.right"
              ) {
                Toggle("", isOn: $clockOutReminderEnabled)
                  .disabled(!clockOutEnabled)
                  .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                  .scaleEffect(0.8, anchor: .topTrailing)
                  .onChange(of: clockOutReminderEnabled) {
                    defaults.set(
                      clockOutReminderEnabled, forKey: "clockOutReminderEnabled"
                    )
                  }
              }
              Divider()
              SettingItemRow(
                title: "Persistent Reminders Interval",
                description:
                  "Set how often you want to be reminded after the initial clock out time.",
                icon: "clock.arrow.2.circlepath"
              ) {
                Picker("", selection: $clockOutReminderInterval) {
                  ForEach(reminderIntervals, id: \.self) { interval in
                    Text(
                      interval == 120
                        ? "2 hours"
                        : "\(interval) min\(interval == 1 ? "" : "s")"
                    )
                  }
                  Text("OFF").tag(0)
                }
                .pickerStyle(.menu)
                .frame(width: 100)
                .disabled(!clockOutEnabled || !clockOutReminderEnabled)
                .onChange(of: clockOutReminderInterval) {
                  defaults.set(
                    clockOutReminderInterval, forKey: "clockOutReminderInterval"
                  )
                }
              }
            }
          }

          InfoBox {
            HStack {
              Text(
                "When it's time to clock out, you'll receive a notification. If persistent reminders are enabled, you'll get additional notifications at the specified interval."
              )
              .foregroundStyle(.secondary)
              Spacer()
            }
          }
          Spacer()
        }
      }
    }
  }

  private func toggleDay(_ day: Int) {
    if selectedDays.contains(day) {
      selectedDays.remove(day)
    } else {
      selectedDays.insert(day)
    }
    defaults.set(Array(selectedDays), forKey: "clockOutSelectedDays")
    Notifier.shared.updateSettings()
  }
}

struct DayToggleButton: View {
  let day: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(day)
        .font(.caption)
        .frame(width: 35, height: Style.Button.heightXS)
        .background(
          isSelected ? AnyView(Style.Colors.accent) : AnyView(Rectangle().fill(Style.Button.bg))
        )
        .overlay(
          RoundedRectangle(cornerRadius: Style.Layout.cornerRadius / 2)
            .stroke(
              Style.Button.border,
              lineWidth: Style.Layout.borderWidth)
        )
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(Style.Layout.cornerRadius / 2)
    }
    .buttonStyle(.borderless)
  }
}
