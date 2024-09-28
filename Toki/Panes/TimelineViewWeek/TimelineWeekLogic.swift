import SwiftUI

class TimelineWeekLogic: ObservableObject {
  @Published var weekDays: [Date] = []
  @Published var activities: [Date: [ActivityEntry]] = [:]

  let segmentCountPerDay: Int = 6 * 24
  private let calendar = Calendar.current
  private let day = Day()

  @Published private(set) var weekStart: Date

  init() {
    self.weekStart = Calendar.current.date(
      from: Calendar.current.dateComponents(
        [.yearForWeekOfYear, .weekOfYear], from: Date()))!
    updateWeekDays(
      firstDayOfWeek: UserDefaults.standard.integer(forKey: "firstDayOfWeek"))
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
      updateWeekDays(
        firstDayOfWeek: UserDefaults.standard.integer(forKey: "firstDayOfWeek"))
      loadData()
    }
  }

  func updateWeekDays(firstDayOfWeek: Int) {
    let adjustedFirstDayOfWeek = firstDayOfWeek == 1 ? 1 : firstDayOfWeek
    let adjustedWeekStart = calendar.date(
      bySetting: .weekday, value: adjustedFirstDayOfWeek, of: weekStart)!
    weekDays = (0...6).map {
      calendar.date(byAdding: .day, value: $0, to: adjustedWeekStart)!
    }
  }

  func formatWeekday(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    return formatter.string(from: date)
  }

  func mergeAdjacentSegments(for day: Date) -> [(Int, Int)] {
    guard activities[day] != nil else { return [] }

    var mergedSegments: [(Int, Int)] = []
    var currentStart: Int?

    for segment in 0..<segmentCountPerDay {
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

    if let start = currentStart {
      mergedSegments.append((start, segmentCountPerDay - 1))
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

  func yPositionForSegment(_ segment: Int, height: CGFloat) -> CGFloat {
    CGFloat(segment) / CGFloat(segmentCountPerDay) * height
  }

  func colorForSegment(_ segment: Int, day: Date) -> Color {
    Style.Colors.accent.opacity(0.8)
  }
}
