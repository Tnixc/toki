import SwiftUI

struct ClockOutSettingsTab: View {
  @State private var clockOutTime: Date
  @State private var clockOutEnabled: Bool
  @State private var clockOutReminderEnabled: Bool
  @State private var clockOutReminderInterval: Int

  private let reminderIntervals = [1, 3, 5, 10, 15, 20, 30, 60, 120]
  private let defaults = UserDefaults.standard

  init() {
    let defaultClockOutTime =
      Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
    _clockOutTime = State(
      initialValue: defaults.object(forKey: "clockOutTime") as? Date
        ?? defaultClockOutTime)
    _clockOutEnabled = State(
      initialValue: defaults.bool(forKey: "clockOutEnabled"))
    _clockOutReminderEnabled = State(
      initialValue: defaults.bool(forKey: "clockOutReminderEnabled"))
    _clockOutReminderInterval = State(
      initialValue: defaults.integer(forKey: "clockOutReminderInterval"))

    if defaults.object(forKey: "clockOutReminderInterval") == nil {
      defaults.set(15, forKey: "clockOutReminderInterval")
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 10) {
        Text("Clock Out").font(.title).padding()
        SettingItemGroup {
          VStack(alignment: .leading, spacing: 5) {
            SettingItemRow(
              title: "Enable Clock Out",
              description: "Turn on/off clock out notifications",
              icon: "bell.badge"
            ) {
              Toggle("", isOn: $clockOutEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .scaleEffect(0.8, anchor: .topTrailing)
                .onChange(of: clockOutEnabled) {
                  defaults.set(clockOutEnabled, forKey: "clockOutEnabled")
                  Notifier.shared.updateSettings()
                }
            }
            Divider()
            SettingItemRow(
              title: "Clock Out Time",
              description: "Set the time you want to be reminded to clock out.",
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
            HStack {
              Spacer()
              CustomButton(
                action: {
                  Notifier.shared.showOverlay()
                }, label: "Show overlay", icon: "circle.dotted", height: 36)
            }
          }
        }
        SettingItemGroup {
          VStack(alignment: .leading, spacing: 5) {
            SettingItemRow(
              title: "Enable Persistent Reminders",
              description:
                "Turn on/off clock out persistent reminder notifications",
              icon: "bell.and.waves.left.and.right"
            ) {
              Toggle("", isOn: $clockOutReminderEnabled)
                .disabled(!clockOutEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
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
                      ? "2 hours" : "\(interval) min\(interval == 1 ? "" : "s")"
                  )
                }
                Text("OFF").tag(0)
              }
              .pickerStyle(.menu)
              .frame(width: 100)
              .disabled(!clockOutEnabled || !clockOutReminderEnabled)
              .onChange(of: clockOutReminderInterval) {
                defaults.set(
                  clockOutReminderInterval, forKey: "clockOutReminderInterval")
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
