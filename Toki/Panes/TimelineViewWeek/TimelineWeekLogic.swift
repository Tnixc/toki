import SwiftUI

class TimelineWeekLogic: ObservableObject {
  @Published var selectedDate: Date = Date()
  @Published var showDatePicker = false
  @Published var weekDays: [Date] = []
  @Published private(set) var weekActivities: [Date: [ActivityEntry]] = [:]
  @Published private(set) var isLoading = false

  private let calendar = Calendar.current
  private let day = Day()
  private let segmentDuration: TimeInterval = 20 * 60  // 20 minutes
  private let segmentsPerDay: Int = 72  // 24 hours * 3 segments per hour

  var weekString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    let startOfWeek = weekDays.first ?? selectedDate
    let endOfWeek = weekDays.last ?? selectedDate
    return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
  }

  var isCurrentWeek: Bool {
    calendar.isDate(selectedDate, equalTo: Date(), toGranularity: .weekOfYear)
  }

  var formattedTotalActiveTime: String {
    let totalSeconds = weekActivities.values.flatMap { $0 }.count * Watcher().INTERVAL
    return formatDuration(TimeInterval(totalSeconds))
  }

  var mostActiveDay: String {
    guard let mostActiveDate = weekActivities.max(by: { $0.value.count < $1.value.count })?.key
    else {
      return "N/A"
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter.string(from: mostActiveDate)
  }

  init() {
    updateWeekDays()
  }

  func loadData() {
    isLoading = true
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else { return }

      let newWeekActivities = self.weekDays.reduce(into: [Date: [ActivityEntry]]()) { result, day in
        result[day] = self.day.getActivityForDay(date: day)
      }

      DispatchQueue.main.async {
        self.weekActivities = newWeekActivities
        self.isLoading = false
        self.objectWillChange.send()
      }
    }
  }

  func changeWeek(by value: Int) {
    if let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
      selectedDate = min(newDate, Date())
      updateWeekDays()
      loadData()
    }
  }

  func updateWeekDays() {
    let startOfWeek = calendar.date(
      from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
    weekDays = (0...6).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
  }

  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d"
    return formatter.string(from: date)
  }

  func xPositionForTime(_ time: Date, width: CGFloat) -> CGFloat {
    let startOfDay = calendar.startOfDay(for: time)
    let secondsSinceMidnight = time.timeIntervalSince(startOfDay)
    return (CGFloat(secondsSinceMidnight) / CGFloat(86400)) * width
  }

  func colorForApp(_ appName: String) -> Color {
    let hash = appName.unicodeScalars.reduce(0) { $0 + $1.value }
    let index = Int(hash) % colorSet.count
    return colorSet[index]
  }

  func activitiesForDay(_ day: Date) -> [ActivityInfo] {
    guard let activities = weekActivities[day] else { return [] }

    var activityInfos: [ActivityInfo] = []
    let startOfDay = calendar.startOfDay(for: day)

    for segmentIndex in 0..<segmentsPerDay {
      let segmentStart = startOfDay.addingTimeInterval(Double(segmentIndex) * segmentDuration)
      let segmentEnd = segmentStart.addingTimeInterval(segmentDuration)

      let segmentActivities = activities.filter {
        $0.timestamp >= segmentStart && $0.timestamp < segmentEnd
      }

      if let dominantApp = findDominantApp(in: segmentActivities) {
        activityInfos.append(
          ActivityInfo(appName: dominantApp, startTime: segmentStart, endTime: segmentEnd))
      }
    }

    return mergeConsecutiveActivities(activityInfos)
  }

  private func findDominantApp(in activities: [ActivityEntry]) -> String? {
    let appCounts = activities.reduce(into: [:]) { counts, activity in
      counts[activity.appName, default: 0] += 1
    }
    return appCounts.max(by: { $0.value < $1.value })?.key
  }

  private func mergeConsecutiveActivities(_ activities: [ActivityInfo]) -> [ActivityInfo] {
    var merged: [ActivityInfo] = []
    var current: ActivityInfo?

    for activity in activities {
      if let currentActivity = current, currentActivity.appName == activity.appName {
        current = ActivityInfo(
          appName: activity.appName, startTime: currentActivity.startTime, endTime: activity.endTime
        )
      } else {
        if let currentActivity = current {
          merged.append(currentActivity)
        }
        current = activity
      }
    }

    if let lastActivity = current {
      merged.append(lastActivity)
    }

    return merged
  }

  private func formatDuration(_ seconds: TimeInterval) -> String {
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    return String(format: "%dh %dm", hours, minutes)
  }
}

struct ActivityInfo: Identifiable {
  let id = UUID()
  let appName: String
  let startTime: Date
  let endTime: Date
}
