//
//  ExportManager.swift
//  Toki
//
//  Created by tnixc on 22/9/2024.
//

import Foundation
import SQLite

class ExportManager {
  static let shared = ExportManager()

  private let db: Connection
  private let activities: Table
  private let timestamp = Expression<Date>("timestamp")
  private let appName = Expression<String>("app_name")

  private init() {
    let path = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
    ).first!
    db = try! Connection("\(path)/activities.sqlite3")
    activities = Table("activities")
  }

  func exportAllData(to url: URL) throws {
    let query = activities.order(timestamp.asc)
    try exportData(query: query, to: url)
  }

  func exportDateRange(from startDate: Date, to endDate: Date, to url: URL)
    throws
  {
    let query =
      activities
      .filter(timestamp >= startDate && timestamp <= endDate)
      .order(timestamp.asc)
    try exportData(query: query, to: url)
  }

  private func exportData(query: Table, to url: URL) throws {
    var csvString = "Timestamp,App Name\n"

    for row in try db.prepare(query) {
      let timestampString = DateFormatter.localizedString(
        from: row[timestamp], dateStyle: .medium, timeStyle: .medium)
      csvString += "\(timestampString),\(row[appName])\n"
    }

    try csvString.write(to: url, atomically: true, encoding: .utf8)
  }
}
