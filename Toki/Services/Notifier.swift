import Foundation
import UserNotifications

class Notifier {
  static let shared = Notifier()

  private var lastClockOutCheck: Date?
  private var clockOutTime: Date?
  private var lastReminderTime: Date?
  private let defaults = UserDefaults.standard

  private init() {
    updateSettings()
    requestNotificationPermission()
  }

  func updateSettings() {
    clockOutTime = defaults.object(forKey: "clockOutTime") as? Date
  }

  func checkClockOutTime() {
    guard defaults.bool(forKey: "clockOutEnabled"),
      let clockOutTime = self.clockOutTime
    else {
      return
    }

    let now = Date()
    let calendar = Calendar.current

    let clockOutComponents = calendar.dateComponents(
      [.hour, .minute], from: clockOutTime)
    let currentComponents = calendar.dateComponents(
      [.hour, .minute], from: now)

    if clockOutComponents == currentComponents {
      if lastClockOutCheck == nil
        || !calendar.isDate(lastClockOutCheck!, inSameDayAs: now)
      {
        clockOutMain()
        lastClockOutCheck = now
        lastReminderTime = now
      }
    } else if let lastReminder = lastReminderTime,
      defaults.bool(forKey: "clockOutReminderEnabled")
    {
      let reminderInterval = TimeInterval(
        defaults.integer(forKey: "clockOutReminderInterval") * 60)
      if now.timeIntervalSince(lastReminder) >= reminderInterval {
        clockOutReminder()
        lastReminderTime = now
      }
    }
  }

  private func clockOutMain() {
    sendNotification(title: "Clock Out", body: "It's time to clock out!")
  }

  private func clockOutReminder() {
    sendNotification(
      title: "Clock Out Reminder", body: "Don't forget to clock out!")
  }

  private func sendNotification(title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default

    let request = UNNotificationRequest(
      identifier: UUID().uuidString, content: content, trigger: nil)

    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("Error sending notification: \(error.localizedDescription)")
      }
    }
  }

  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [
      .alert, .sound, .badge,
    ]) { granted, error in
      if granted {
        print("Notification permission granted")
      } else if let error = error {
        print(
          "Error requesting notification permission: \(error.localizedDescription)"
        )
      }
    }
  }
}
