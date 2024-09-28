import AppKit
import SQLite

typealias Expression = SQLite.Expression

class Watcher {
  static let INTERVAL = 6
  static let IDLE_TIME = 60
  static let dbURL: URL = {
    let fileManager = FileManager.default
    let appSupportURL = fileManager.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    ).first!
    let appDirectoryURL = appSupportURL.appendingPathComponent(
      "Toki", isDirectory: true)

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

    return appDirectoryURL.appendingPathComponent("activities.sqlite3")
  }()

  private var timer: Timer?
  private let db: Connection
  private let activities: Table
  private let timestamp = Expression<Date>("timestamp")
  private let appName = Expression<String>("app_name")

  init() {
    // Initialize SQLite database
    db = try! Connection(Watcher.dbURL.path)

    activities = Table("activities")
    try! db.run(
      activities.create(ifNotExists: true) { t in
        t.column(timestamp)
        t.column(appName)
      })
  }

  func start() {
    timer = Timer.scheduledTimer(
      withTimeInterval: TimeInterval(Watcher.INTERVAL), repeats: true
    ) { [weak self] _ in
      self?.checkActivity()
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
  }

  private func checkActivity() {
    //clock out
    Notifier.shared.checkClockOutTime()

    // watcher
    let frontmostApp = NSWorkspace.shared.frontmostApplication
    let appName = frontmostApp?.localizedName ?? "Unknown"
    let idle =
      Int(
        CGEventSource.secondsSinceLastEventType(
          .combinedSessionState, eventType: .mouseMoved)) > Watcher.IDLE_TIME
      && Int(
        CGEventSource.secondsSinceLastEventType(
          .combinedSessionState, eventType: .keyDown)) > Watcher.IDLE_TIME

    // Log to database
    if appName != "loginwindow" && !idle {
      let insert = activities.insert(
        timestamp <- Date(),
        self.appName <- appName
      )
      do {
        try db.run(insert)
      } catch {
        print("Error inserting into database: \(error)")
      }
    }
  }
}
