// StorageSettingsTab.swift

import SQLite
import SwiftUI

typealias View = SwiftUI.View
typealias Binding = SwiftUI.Binding
typealias Table = SQLite.Table

struct StorageSettingsTab: View {
  @State private var showingConfirmation = false
  @State private var databaseInfo: DatabaseInfo = DatabaseInfo()

  var body: some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {
      Text("Storage").font(.title).padding()
      InfoSection(databaseInfo: databaseInfo)
      Divider()
      ClearDatabaseButton(
        showingConfirmation: $showingConfirmation, databaseInfo: $databaseInfo)
      Spacer()
    }
    .onAppear(perform: loadDatabaseInfo)
  }

  private func loadDatabaseInfo() {
    let dbManager = DatabaseManager()
    databaseInfo = dbManager.getDatabaseInfo()
  }
}

struct InfoSection: View {
  let databaseInfo: DatabaseInfo

  var body: some View {
    InfoBox {
      VStack(alignment: .leading, spacing: Style.Layout.padding) {
        InfoRow(
          title: "Recording Interval",
          value: "Every \(Constants.interval) seconds")
        InfoRow(title: "Number of Entries", value: "\(databaseInfo.entryCount)")
        InfoRow(title: "Earliest Entry", value: databaseInfo.earliestEntry)
        InfoRow(title: "Database Size", value: databaseInfo.dbSize)
      }.padding(5)
    }

    InfoBox {
      HStack {
        Text(
          "The projected storage space needed is 100-200MB per year with normal usage. Data is not logged when you are idle."
        )
        .foregroundStyle(.secondary)
        Spacer()
      }.padding(5)
    }
  }
}

struct InfoRow: View {
  let title: String
  let value: String

  var body: some View {
    HStack {
      Text(title)
        .font(.headline)
      Spacer()
      Text(value)
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
  }
}

struct ClearDatabaseButton: View {
  @Binding var showingConfirmation: Bool
  @Binding var databaseInfo: DatabaseInfo

  var body: some View {
    Button(action: {
      showingConfirmation = true
    }) {
      HStack {
        Image(systemName: "trash.fill").foregroundColor(.primary).fontWeight(
          .semibold)
        Text("Clear Database").foregroundColor(.primary).fontWeight(.semibold)
      }.padding()
    }
    .background(Color.red.opacity(0.2))
    .hoverEffect()
    .frame(height: Style.Button.height)
    .cornerRadius(Style.Layout.cornerRadius)
    .buttonStyle(.borderless)
    .alert(isPresented: $showingConfirmation) {
      Alert(
        title: Text("Clear Database"),
        message: Text(
          "Are you sure you want to clear the entire database? This action cannot be undone."
        ),
        primaryButton: .destructive(Text("Clear")) {
          clearDatabase()
        },
        secondaryButton: .cancel()
      )
    }
    .overlay(
      RoundedRectangle(cornerRadius: Style.Layout.cornerRadius).stroke(
        Color.red, lineWidth: Style.Layout.borderWidth))
  }

  private func clearDatabase() {
    let dbManager = DatabaseManager()
    dbManager.clearDatabase()
    databaseInfo = dbManager.getDatabaseInfo()
  }
}

struct DatabaseInfo {
  var entryCount: Int = 0
  var earliestEntry: String = "N/A"
  var dbSize: String = "N/A"
}

class DatabaseManager {
  private let db: Connection
  private let activities: Table

  init() {
    db = try! Connection(Watcher.dbURL.path)
    activities = Table("activities")
  }

  func getDatabaseInfo() -> DatabaseInfo {
    var info = DatabaseInfo()

    do {
      info.entryCount = try db.scalar(activities.count)

      if let earliestTimestamp: Date = try db.pluck(
        activities.select(Expression<Date>("timestamp")).order(
          Expression<Date>("timestamp").asc))?.get(
          Expression<Date>("timestamp"))
      {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        info.earliestEntry = formatter.string(from: earliestTimestamp)
      }

      if let dbPath = db.description.components(
        separatedBy: Constants.dbFileName
      ).first {
        let fileURL = URL(fileURLWithPath: dbPath + Constants.dbFileName)
        let attributes = try FileManager.default.attributesOfItem(
          atPath: fileURL.path)
        let fileSize = attributes[.size] as! Int64
        info.dbSize = ByteCountFormatter.string(
          fromByteCount: fileSize, countStyle: .file)
      }
    } catch {
      print("Error getting database info: \(error)")
    }

    return info
  }

  func clearDatabase() {
    do {
      try db.run(activities.delete())
      print("Database cleared successfully")
    } catch {
      print("Error clearing database: \(error)")
    }
  }
}
