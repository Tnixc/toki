import Foundation
import SQLite

struct ActivityEntry: Equatable {
  let timestamp: Date
  let appName: String
  let isIdle: Bool

  static func == (lhs: ActivityEntry, rhs: ActivityEntry) -> Bool {
    return lhs.timestamp == rhs.timestamp && lhs.appName == rhs.appName
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

  func getActivityForDay(date: Date) -> [ActivityEntry] {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

    let query =
      activities
      .filter(timestamp >= startOfDay && timestamp < endOfDay)
      .order(timestamp.asc)

    var activityEntries: [ActivityEntry] = []

    do {
      for activity in try db.prepare(query) {
        activityEntries.append(
          ActivityEntry(
            timestamp: activity[timestamp],
            appName: activity[appName],
            isIdle: activity[isIdle]
          ))
      }
    } catch {
      print("Error querying database: \(error)")
    }

    return activityEntries
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

    var usages = [String: TimeInterval]()
    do {
      for row in try db.prepare(query) {
        let currentApp = row[appName]
        usages[currentApp, default: 0] += Double(Watcher().INTERVAL)
      }
    } catch {
      print("Error querying database: \(error)")
    }

    let sortedUsage = usages.map {
      AppUsage(appName: $0.key, duration: $0.value)
    }

    .sorted { $0.duration > $1.duration }
    return sortedUsage
  }
}
