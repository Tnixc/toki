import Foundation
import SwiftUI

extension Notification.Name {
  static let firstDayOfWeekChanged = Notification.Name("firstDayOfWeekChanged")
}

func triggerHapticFeedback() {
  NSHapticFeedbackManager.defaultPerformer.perform(
    .levelChange, performanceTime: .default)
}

func getDay(from dateComponents: DateComponents) -> String {
  guard let date = Calendar.current.date(from: dateComponents) else {
    return "Invalid Date"
  }
  return date.formatted(.dateTime.day(.twoDigits))
}

func getMonth(from dateComponents: DateComponents) -> String {
  guard let date = Calendar.current.date(from: dateComponents) else {
    return "Invalid Date"
  }
  return date.formatted(.dateTime.month(.abbreviated))
}

func getWeekday(from dateComponents: DateComponents) -> String {
  guard let date = Calendar.current.date(from: dateComponents) else {
    return "Invalid Date"
  }
  return date.formatted(.dateTime.weekday(.abbreviated))
}

func formatDate(components: DateComponents) -> String {
  guard let date = Calendar.current.date(from: components) else {
    return "Invalid date"
  }

  let today = Calendar.current.startOfDay(for: Date())
  let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

  if Calendar.current.isDate(date, inSameDayAs: today) {
    return "Today"
  } else if Calendar.current.isDate(date, inSameDayAs: yesterday) {
    return "Yesterday"
  } else {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.string(from: date)
  }
}

func formatDateLong(components: DateComponents) -> String {
  let calendar = Calendar.current
  guard let date = calendar.date(from: components) else {
    return "Invalid Date"
  }

  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = DateFormatter.dateFormat(
    fromTemplate: "EEEE MMM d, yyyy", options: 0, locale: Locale.current)

  return dateFormatter.string(from: date)
}

class SettingsManager {
  static let shared = SettingsManager()

  private let defaults = UserDefaults.standard

  private init() {}

  func bool(forKey key: String) -> Bool {
    return defaults.bool(forKey: key)
  }

  func set(_ value: Bool, forKey key: String) {
    defaults.set(value, forKey: key)
  }
}

public let colorSet: [Color] = [
  Color.blue.opacity(0.7),
  Color.cyan.opacity(0.7),
  Color.green.opacity(0.7),
  Color.indigo.opacity(0.7),
  Color.mint.opacity(0.7),
  Color.orange.opacity(0.7),
  Color.pink.opacity(0.7),
  Color.purple.opacity(0.7),
  Color.red.opacity(0.7),
  Color.teal.opacity(0.7),
  Color.yellow.opacity(0.7),
]

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:  // RGB (12-bit)
      (a, r, g, b) = (
        255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
      )
    case 6:  // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}

func mod(_ a: Int, _ n: Int) -> Int {
  precondition(n > 0, "modulus must be positive")
  let r = a % n
  return r >= 0 ? r : r + n
}

func endOfDayTime() -> Date {
  let defaults = UserDefaults.standard
  if let savedTime = defaults.object(forKey: "endOfDayTime") as? Date {
    return savedTime
  } else {
    return Calendar.current.date(from: DateComponents(hour: 4, minute: 0))
      ?? Date()
  }
}
