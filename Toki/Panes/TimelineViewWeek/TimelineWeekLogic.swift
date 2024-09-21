import SwiftUI

class TimelineWeekLogic: ObservableObject {
  @Published var selectedWeekStart: Date
  @Published var weekActivities: [[ActivityEntry]] = Array(
    repeating: [], count: 7)
  @Published var totalActiveTime: TimeInterval = 0
  @Published var mostUsedApps: [AppUsage] = []
  @Published var isLoading = false
  @Published var mostActiveDay: String = ""

  private let calendar = Calendar.current
  private let day = Day()

  let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  let hourLabels = (0...23).map { String(format: "%02d", $0) }
  let timelineHeight: CGFloat = 480

  init() {
    selectedWeekStart =
      calendar.date(
        from: calendar.dateComponents(
          [.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
  }

  var weekRangeString: String {
    let endOfWeek = calendar.date(
      byAdding: .day, value: 6, to: selectedWeekStart)!
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d"
    return
      "\(dateFormatter.string(from: selectedWeekStart)) - \(dateFormatter.string(from: endOfWeek))"
  }

  var isCurrentWeekSelected: Bool {
    calendar.isDate(
      selectedWeekStart, equalTo: Date(), toGranularity: .weekOfYear)
  }

  var averageDailyActiveTime: TimeInterval {
    totalActiveTime / 7
  }

  func loadData() {
    DispatchQueue.main.async {
      self.isLoading = true
    }

    DispatchQueue.global(qos: .userInitiated).async {
      var newWeekActivities: [[ActivityEntry]] = Array(repeating: [], count: 7)
      var newTotalActiveTime: TimeInterval = 0
      var allAppUsages: [String: TimeInterval] = [:]
      var dailyActiveTimes: [TimeInterval] = []

      for dayOffset in 0..<7 {
        guard
          let currentDate = self.calendar.date(
            byAdding: .day, value: dayOffset, to: self.selectedWeekStart)
        else { continue }
        let activities = self.day.getActivityForDay(date: currentDate)
        newWeekActivities[dayOffset] = activities

        let dailyAppUsages = self.calculateAppUsage(for: activities)
        for (app, duration) in dailyAppUsages {
          allAppUsages[app, default: 0] += duration
        }

        let dailyActiveTime = dailyAppUsages.values.reduce(0, +)
        dailyActiveTimes.append(dailyActiveTime)
        newTotalActiveTime += dailyActiveTime
      }

      let newMostUsedApps = allAppUsages.map {
        AppUsage(appName: $0.key, duration: $0.value)
      }
      .sorted { $0.duration > $1.duration }

      var newMostActiveDay = ""
      if let maxActiveTime = dailyActiveTimes.max(),
        let maxActiveDayIndex = dailyActiveTimes.firstIndex(of: maxActiveTime)
      {
        newMostActiveDay = self.dayNames[maxActiveDayIndex]
      }

      DispatchQueue.main.async {
        self.weekActivities = newWeekActivities
        self.totalActiveTime = newTotalActiveTime
        self.mostUsedApps = newMostUsedApps
        self.mostActiveDay = newMostActiveDay
        self.isLoading = false
      }
    }
  }

  func changeWeek(by value: Int) {
    if let newDate = calendar.date(
      byAdding: .weekOfYear, value: value, to: selectedWeekStart)
    {
      selectedWeekStart = min(newDate, calendar.startOfDay(for: Date()))
    }
  }

  func activitiesForDay(_ dayIndex: Int) -> [ActivityEntry] {
    return weekActivities[dayIndex]
  }

  private func calculateAppUsage(for activities: [ActivityEntry]) -> [String:
    TimeInterval]
  {
    var appUsage: [String: TimeInterval] = [:]
    for activity in activities {
      appUsage[activity.appName, default: 0] += TimeInterval(Watcher().INTERVAL)
    }
    return appUsage
  }

  func colorForApp(_ appName: String) -> Color {
    let hash = appName.unicodeScalars.reduce(0) { $0 + $1.value }
    return colorSet[Int(hash) % colorSet.count]
  }

  func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    return String(format: "%dh %02dm", hours, minutes)
  }
}
