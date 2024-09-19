import Foundation
import SQLite

struct MinuteActivity: Equatable {
  let minute: Date
  let appName: String
  let isIdle: Bool

  static func == (lhs: MinuteActivity, rhs: MinuteActivity) -> Bool {
    return lhs.minute == rhs.minute && lhs.appName == rhs.appName
      && lhs.isIdle == rhs.isIdle
  }
}

struct AppUsage {
  let appName: String
  let duration: TimeInterval
}

class Day {
  private let db: Connection
  private let activities: Table
  private let timestamp = Expression<Date>("timestamp")
  private let appName = Expression<String>("app_name")
  private let isIdle = Expression<Bool>("is_idle")

  init() {
    let path = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
    ).first!

    db = try! Connection("\(path)/activities.sqlite3")
    activities = Table("activities")
  }

  func getActivityForDay(date: Date) -> [MinuteActivity] {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)  // Use the provided date
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

    let query =
      activities
      .filter(timestamp >= startOfDay && timestamp < endOfDay)
      .order(timestamp.asc)

    var minuteActivities: [MinuteActivity] = []
    var currentMinute: Date?
    var currentMinuteApps: [String: Int] = [:]
    var currentMinuteIdleCount = 0

    do {
      for activity in try db.prepare(query) {
        let activityMinute = calendar.date(
          bySetting: .second, value: 0, of: activity[timestamp])!

        if currentMinute != activityMinute {
          if let minute = currentMinute {
            let mostUsedApp =
              currentMinuteApps.max(by: { $0.value < $1.value })?.key
              ?? "Unknown"
            let isIdle = currentMinuteIdleCount > 5  // More than half of the checks were idle
            minuteActivities.append(
              MinuteActivity(
                minute: minute, appName: mostUsedApp, isIdle: isIdle))
          }

          currentMinute = activityMinute
          currentMinuteApps = [:]
          currentMinuteIdleCount = 0
        }

        currentMinuteApps[activity[appName], default: 0] += 1
        if activity[isIdle] {
          currentMinuteIdleCount += 1
        }
      }

      // Add the last minute
      if let minute = currentMinute {
        let mostUsedApp =
          currentMinuteApps.max(by: { $0.value < $1.value })?.key ?? "Unknown"
        let isIdle = currentMinuteIdleCount > 5
        minuteActivities.append(
          MinuteActivity(minute: minute, appName: mostUsedApp, isIdle: isIdle))
      }
    } catch {
      print("Error querying database: \(error)")
    }

    return minuteActivities
  }

  func getMostUsedApps(for date: Date) -> [AppUsage] {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

    let query =
      activities
      .filter(timestamp >= startOfDay && timestamp < endOfDay && !isIdle)
      .select(appName, timestamp)
      .order(timestamp.asc)

    var appUsage: [String: TimeInterval] = [:]
    var lastTimestamp: Date?
    var lastApp: String?

    do {
      for row in try db.prepare(query) {
        let currentApp = row[appName]
        let currentTimestamp = row[timestamp]

        if let lastApp = lastApp, let lastTimestamp = lastTimestamp {
          let duration = currentTimestamp.timeIntervalSince(lastTimestamp)
          appUsage[lastApp, default: 0] += duration
        }

        lastApp = currentApp
        lastTimestamp = currentTimestamp
      }
    } catch {
      print("Error querying database: \(error)")
    }

    let sortedUsage = appUsage.map {
      AppUsage(appName: $0.key, duration: $0.value)
    }
    .sorted { $0.duration > $1.duration }

    return sortedUsage
  }
}
