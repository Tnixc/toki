import Foundation
import SQLite

struct ActivityEntry: Equatable {
  let timestamp: Date
  let appName: String

  static func == (lhs: ActivityEntry, rhs: ActivityEntry) -> Bool {
    return lhs.timestamp == rhs.timestamp && lhs.appName == rhs.appName
  }
}

struct AppUsage: Equatable {
  let appName: String
  let duration: TimeInterval
  static func == (lhs: AppUsage, rhs: AppUsage) -> Bool {
    return lhs.duration == rhs.duration && lhs.appName == rhs.appName
  }
}

class Day {
  private let db: Connection
  private let activities: Table
  private let timestamp = Expression<Date>("timestamp")
  private let appName = Expression<String>("app_name")

  init() {
    // Initialize SQLite database
    let fileManager = FileManager.default
    let appSupportURL = fileManager.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    ).first!
    let appDirectoryURL = appSupportURL.appendingPathComponent(
      Bundle.main.name, isDirectory: true)

    // Create the app directory if it doesn't exist
    if !fileManager.fileExists(atPath: appDirectoryURL.path) {
      do {
        try fileManager.createDirectory(
          at: appDirectoryURL, withIntermediateDirectories: true,
          attributes: nil)
      } catch {
        print("Error creating app directory: \(error)")
      }
    }

    let dbURL = appDirectoryURL.appendingPathComponent("activities.sqlite3")

    db = try! Connection(dbURL.path)

    activities = Table("activities")
    try! db.run(
      activities.create(ifNotExists: true) { t in
        t.column(timestamp)
        t.column(appName)
      })
  }

  func getActivityForDay(date: Date) -> [ActivityEntry] {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(
      byAdding: .hour, value: 24 + 6, to: startOfDay)!

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
            appName: activity[appName]
          )
        )
      }
    } catch {
      print("Error querying database: \(error)")
    }
    return activityEntries
  }
}
