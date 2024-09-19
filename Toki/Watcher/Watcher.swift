import AppKit
import SQLite

typealias Expression = SQLite.Expression
class Watcher {
  private let IDLE_TIME = 60
  private var timer: Timer?
  private let db: Connection
  private let activities: Table
  private let timestamp = Expression<Date>("timestamp")
  private let appName = Expression<String>("app_name")
  private let isIdle = Expression<Bool>("is_idle")

  init() {
    // Initialize SQLite database
    let path = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
    ).first!

    db = try! Connection("\(path)/activities.sqlite3")

    activities = Table("activities")
    try! db.run(
      activities.create(ifNotExists: true) { t in
        t.column(timestamp)
        t.column(appName)
        t.column(isIdle)
      })
  }

  func start() {
    timer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) {
      [weak self] _ in
      self?.checkActivity()
    }
  }

  func stop() {
    timer?.invalidate()
    timer = nil
  }

  private func checkActivity() {
    let frontmostApp = NSWorkspace.shared.frontmostApplication
    let appName = frontmostApp?.localizedName ?? "Unknown"
    let idle =
      Int(
        CGEventSource.secondsSinceLastEventType(
          .combinedSessionState, eventType: .mouseMoved)) > IDLE_TIME
      && Int(
        CGEventSource.secondsSinceLastEventType(
          .combinedSessionState, eventType: .keyDown)) > IDLE_TIME

    // Log to database
    let insert = activities.insert(
      timestamp <- Date(),
      self.appName <- appName,
      isIdle <- idle
    )

    do {
      try db.run(insert)
      print("Logged activity: \(appName), Idle: \(idle)")
    } catch {
      print("Error inserting into database: \(error)")
    }
  }
}
