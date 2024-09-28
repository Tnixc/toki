import Combine
import SwiftUI

class TimelineWeekLogic: ObservableObject {
  @Published var weekDays: [Date] = []
  @Published var activities: [Date: [ActivityEntry]] = [:]
  @Published var isLoading: Bool = false
  @Published var latestClockOut: Date?
  @Published var earliestClockIn: Date?
  @Published var averageClockIn: Date?
  @Published var averageClockOut: Date?
  @Published var averageActiveTime: TimeInterval = 0

  @AppStorage("showAppColors") private var showAppColors: Bool = true

  let segmentCount = Constants.segmentCount
  private let calendar = Calendar.current
  private let day = Day()
  private var cancellables = Set<AnyCancellable>()
  private let queue = DispatchQueue(
    label: "com.toki.weekDataLoading", qos: .userInitiated,
    attributes: .concurrent)

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
    isLoading = true
    activities.removeAll()

    let group = DispatchGroup()

    for day in weekDays {
      group.enter()
      queue.async { [weak self] in
        guard let self = self else { return }
        let dayActivities = self.day.getActivityForDay(date: day)
        DispatchQueue.main.async {
          self.activities[day] = dayActivities
          group.leave()
        }
      }
    }

    group.notify(queue: .main) { [weak self] in
      guard let self = self else { return }
      self.calculateWeekStats()
      self.isLoading = false
      self.objectWillChange.send()
    }
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
    guard let dayActivities = activities[day] else { return [] }

    var mergedSegments: [(Int, Int)] = []
    var currentStart: Int?

    for segment in 0..<segmentCount {
      if isSegmentActive(segment, for: day, activities: dayActivities) {
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
      mergedSegments.append((start, segmentCount - 1))
    }

    return mergedSegments
  }

  func isSegmentActive(
    _ segment: Int, for day: Date, activities: [ActivityEntry]
  ) -> Bool {
    let segmentStart = calendar.date(
      byAdding: .minute, value: segment * Constants.segmentDuration,
      to: calendar.startOfDay(for: day))!
    let segmentEnd = calendar.date(
      byAdding: .minute, value: (segment + 1) * Constants.segmentDuration,
      to: calendar.startOfDay(for: day))!

    return activities.contains { activity in
      activity.timestamp >= segmentStart && activity.timestamp < segmentEnd
    }
  }

  func colorForSegment(_ segment: Int, day: Date) -> Color {
    guard let dayActivities = activities[day] else { return .clear }

    let segmentStart = calendar.date(
      byAdding: .minute, value: segment * Constants.segmentDuration,
      to: calendar.startOfDay(for: day))!
    let segmentEnd = calendar.date(
      byAdding: .minute, value: (segment + 1) * Constants.segmentDuration,
      to: calendar.startOfDay(for: day))!

    let activitiesInSegment = dayActivities.filter { activity in
      activity.timestamp >= segmentStart && activity.timestamp < segmentEnd
    }

    let opacity =
      (Double(activitiesInSegment.count) * Double(Watcher.INTERVAL))
      / (Double(Constants.segmentDuration * 60))

    if showAppColors {
      let appCounts = activitiesInSegment.reduce(into: [:]) {
        counts, activity in
        counts[activity.appName, default: 0] += 1
      }
      if let dominantApp = appCounts.max(by: { $0.value < $1.value })?.key {
        return colorForApp(dominantApp).opacity(opacity)
      }
    }
    return Style.Colors.accent.opacity(opacity)
  }

  func appsForSegment(_ segment: Int, day: Date) -> [AppUsage] {
    guard let dayActivities = activities[day] else { return [] }

    let segmentStart = calendar.date(
      byAdding: .minute, value: segment * Constants.segmentDuration,
      to: calendar.startOfDay(for: day))!
    let segmentEnd = calendar.date(
      byAdding: .minute, value: (segment + 1) * Constants.segmentDuration,
      to: calendar.startOfDay(for: day))!

    var appUsage: [String: TimeInterval] = [:]

    for activity in dayActivities {
      if activity.timestamp >= segmentStart && activity.timestamp < segmentEnd {
        appUsage[activity.appName, default: 0] += Double(Watcher.INTERVAL)
      }
    }

    return appUsage.map { AppUsage(appName: $0.key, duration: $0.value) }
      .sorted { $0.duration > $1.duration }
  }

  func opacityForSegment(_ segment: Int, day: Date) -> Double {
    guard let dayActivities = activities[day] else { return 0 }

    let segmentStart = calendar.date(
      byAdding: .minute, value: segment * Constants.segmentDuration,
      to: calendar.startOfDay(for: day))!
    let segmentEnd = calendar.date(
      byAdding: .minute, value: (segment + 1) * Constants.segmentDuration,
      to: calendar.startOfDay(for: day))!

    let activitiesInSegment = dayActivities.filter { activity in
      activity.timestamp >= segmentStart && activity.timestamp < segmentEnd
    }

    return Double(activitiesInSegment.count)
      / Double(Constants.segmentDuration / Watcher.INTERVAL)
  }

  func yPositionForSegment(_ segment: Int, height: CGFloat) -> CGFloat {
    CGFloat(segment) / CGFloat(segmentCount) * height
  }

  private func calculateWeekStats() {
    var clockIns: [Date] = []
    var clockOuts: [Date] = []
    var totalActiveTime: TimeInterval = 0

    for day in weekDays {
      if let activities = activities[day] {
        totalActiveTime += Double(activities.count * Watcher.INTERVAL)
        if !activities.isEmpty {
          let first = activities.first?.timestamp
          clockIns.append(first!)
          let last = activities.last?.timestamp
          clockOuts.append(last!)
        }
      }
    }

    averageActiveTime = totalActiveTime / Double(weekDays.count)
    earliestClockIn = clockIns.min()
    latestClockOut = clockOuts.max()

    if !clockIns.isEmpty {
      let totalClockInSeconds = clockIns.reduce(0) {
        $0 + $1.timeIntervalSince1970
      }
      averageClockIn = Date(
        timeIntervalSince1970: totalClockInSeconds / Double(clockIns.count))
    } else {
      averageClockIn = nil
    }

    if !clockOuts.isEmpty {
      let totalClockOutSeconds = clockOuts.reduce(0) {
        $0 + $1.timeIntervalSince1970
      }
      averageClockOut = Date(
        timeIntervalSince1970: totalClockOutSeconds / Double(clockOuts.count))
    } else {
      averageClockOut = nil
    }
  }
}
