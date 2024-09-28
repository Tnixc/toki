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

  let segmentCountPerDay: Int = 6 * 24  // 6 * 10 min segments => 60 mins => 60mins * 24 hours

  private let calendar = Calendar.current
  private let day = Day()
  private var cancellables = Set<AnyCancellable>()

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

    Future<Void, Never> { promise in
      DispatchQueue.global(qos: .userInitiated).async {
        for day in self.weekDays {
          self.activities[day] = self.day.getActivityForDay(date: day)
        }
        self.calculateWeekStats()
        promise(.success(()))
      }
    }
    .receive(on: DispatchQueue.main)
    .sink { [weak self] _ in
      self?.isLoading = false
      self?.objectWillChange.send()
    }
    .store(in: &cancellables)
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
    let opacity = opacityForSegment(segment, day: day)
    return Style.Colors.accent.opacity(opacity)
  }

  func opacityForSegment(_ segment: Int, day: Date) -> Double {
    guard let dayActivities = activities[day] else { return 0 }

    let segmentStart = calendar.date(
      byAdding: .minute, value: segment * 10, to: calendar.startOfDay(for: day))!
    let segmentEnd = calendar.date(
      byAdding: .minute, value: (segment + 1) * 10,
      to: calendar.startOfDay(for: day))!

    let activitiesInSegment = dayActivities.filter { activity in
      activity.timestamp >= segmentStart && activity.timestamp < segmentEnd
    }

    return Double(activitiesInSegment.count) / Double(6)  // 6 is the max number of activities in a 10-minute segment
  }

  private func calculateWeekStats() {
    var totalActiveTime: TimeInterval = 0
    var clockIns: [Date] = []
    var clockOuts: [Date] = []

    for day in weekDays {
      if let activities = activities[day] {
        let (clockIn, clockOut, activeTime) = TimelineUtils.calculateDayStats(
          activities: activities)

        if let clockIn = clockIn {
          clockIns.append(clockIn)
        }

        if let clockOut = clockOut {
          clockOuts.append(clockOut)
        }

        totalActiveTime += activeTime
      }
    }

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      self.averageActiveTime = totalActiveTime / Double(self.weekDays.count)

      self.earliestClockIn = clockIns.min()
      self.latestClockOut = clockOuts.max()

      if !clockIns.isEmpty {
        let totalClockInSeconds = clockIns.reduce(0) {
          $0 + $1.timeIntervalSince1970
        }
        self.averageClockIn = Date(
          timeIntervalSince1970: totalClockInSeconds / Double(clockIns.count))
      } else {
        self.averageClockIn = nil
      }

      if !clockOuts.isEmpty {
        let totalClockOutSeconds = clockOuts.reduce(0) {
          $0 + $1.timeIntervalSince1970
        }
        self.averageClockOut = Date(
          timeIntervalSince1970: totalClockOutSeconds / Double(clockOuts.count))
      } else {
        self.averageClockOut = nil
      }
    }
  }
}
