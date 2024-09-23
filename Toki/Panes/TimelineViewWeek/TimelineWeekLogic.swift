import SwiftUI

class TimelineWeekLogic: ObservableObject {
  @Published var weekDays: [Date] = []
  @Published var activities: [Date: [ActivityEntry]] = [:]

  private let calendar = Calendar.current
  private let day = Day()

  @Published private(set) var weekStart: Date

  init() {
    self.weekStart = Calendar.current.date(
      from: Calendar.current.dateComponents(
        [.yearForWeekOfYear, .weekOfYear], from: Date()))!
  }

  var weekStartString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter.string(from: weekStart)
  }

  var weekEndString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(
      from: calendar.date(byAdding: .day, value: 6, to: weekStart)!)
  }

  var weekRangeString: String {
    "\(weekStartString) - \(weekEndString)"
  }

  var isCurrentWeek: Bool {
    calendar.isDate(weekStart, equalTo: Date(), toGranularity: .weekOfYear)
  }

  func loadData() {
    weekDays = (0...6).map {
      calendar.date(byAdding: .day, value: $0, to: weekStart)!
    }

    for day in weekDays {
      activities[day] = self.day.getActivityForDay(date: day)
    }

    objectWillChange.send()
  }

  func changeWeek(by value: Int) {
    if let newWeekStart = calendar.date(
      byAdding: .weekOfYear, value: value, to: weekStart)
    {
      weekStart = min(newWeekStart, Date())
      loadData()
    }
  }

  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d"
    return formatter.string(from: date)
  }

  func mergeAdjacentSegments(for day: Date) -> [(Int, Int)] {
    guard activities[day] != nil else { return [] }

    var mergedSegments: [(Int, Int)] = []
    var currentStart: Int?

    for segment in 0..<144 {
      if isSegmentActive(segment, for: day) {
        if currentStart == nil {
          currentStart = segment
        }
      } else {
        if let start = currentStart {
          mergedSegments.append((start, segment - 1))
          currentStart = nil
        }
      }
    }

    // Add the last segment if it's active
    if let start = currentStart {
      mergedSegments.append((start, 143))
    }

    return mergedSegments
  }

  func isSegmentActive(_ segment: Int, for day: Date) -> Bool {
    guard let dayActivities = activities[day] else { return false }

    let segmentStart = calendar.date(
      byAdding: .minute, value: segment * 10, to: calendar.startOfDay(for: day))!
    let segmentEnd = calendar.date(
      byAdding: .minute, value: (segment + 1) * 10,
      to: calendar.startOfDay(for: day))!

    return dayActivities.contains { activity in
      activity.timestamp >= segmentStart && activity.timestamp < segmentEnd
    }
  }

  func xPositionForSegment(_ segment: Int, width: CGFloat) -> CGFloat {
    CGFloat(segment) / CGFloat(144) * width
  }

  func colorForSegment(_ segment: Int, day: Date) -> Color {
    guard let dayActivities = activities[day] else { return .clear }

    let segmentStart = calendar.date(
      byAdding: .minute, value: segment * 10, to: calendar.startOfDay(for: day))!
    let segmentEnd = calendar.date(
      byAdding: .minute, value: (segment + 1) * 10,
      to: calendar.startOfDay(for: day))!

    let segmentActivities = dayActivities.filter { activity in
      activity.timestamp >= segmentStart && activity.timestamp < segmentEnd
    }

    if let dominantApp = segmentActivities.max(by: { $0.appName < $1.appName })?
      .appName
    {
      return colorForApp(dominantApp)
    }

    return .clear
  }

  func colorForApp(_ appName: String) -> Color {
    let hash = appName.unicodeScalars.reduce(0) { $0 + $1.value }
    let index = Int(hash) % colorSet.count
    return colorSet[index]
  }

  func formatDuration(_ duration: TimeInterval) -> String {
    TimelineUtils.formatDuration(duration) ?? "N/A"
  }

  func activeTimeForDay(_ day: Date) -> TimeInterval {
    guard let dayActivities = activities[day] else { return 0 }
    return TimelineUtils.calculateDayStats(activities: dayActivities).2
  }

  func clockInTimeForDay(_ day: Date) -> String {
    guard let dayActivities = activities[day],
      let clockInTime = TimelineUtils.calculateDayStats(
        activities: dayActivities
      ).0
    else {
      return "N/A"
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: clockInTime)
  }

  func clockOutTimeForDay(_ day: Date) -> String {
    guard let dayActivities = activities[day],
      let clockOutTime = TimelineUtils.calculateDayStats(
        activities: dayActivities
      ).1
    else {
      return "N/A"
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: clockOutTime)
  }
}
