import Combine
import SwiftUI

class TimelineDayLogic: ObservableObject {
  @AppStorage("showAppColors") private var showAppColors: Bool = true {
    didSet {
      objectWillChange.send()
    }
  }

  @Published var hoveredSegment: Int? = nil
  @Published var isHovering: Bool = false
  @Published var hoverPosition: CGFloat = 0
  @Published var selectedDate: DateComponents
  @Published var showDatePicker = false
  @Published var currentHoverSegment: Int?
  @Published var mostUsedApps: [AppUsage] = []
  @Published var activities: [ActivityEntry] = []
  @Published var clockInTime: Date?
  @Published var clockOutTime: Date?
  @Published var activeTime: TimeInterval = 0
  @Published var isLoading = false

  let segmentCount = Constants.segmentCount

  private let queue = DispatchQueue(
    label: "com.toki.dataLoading", qos: .userInitiated)

  let useColors = SettingsManager.shared.bool(forKey: "showAppColors")
  let calendar = Calendar.current
  let day = Day()

  // Constants
  let timelineHeight: CGFloat = 95
  let segmentDuration: Int = 10
  let hoverLineExtension: CGFloat = 10

  private var cachedActivities: [ActivityEntry] = []
  private var appUsageDurations: [String: TimeInterval] = [:]
  private var segmentData: [SegmentInfo] = []

  init() {
    let today = Date()
    self.selectedDate = calendar.dateComponents(
      [.year, .month, .day], from: today)
  }

  func loadData(for dateComponents: DateComponents) {
    isLoading = true

    cachedActivities.removeAll()
    segmentData.removeAll()

    queue.async { [weak self] in
      guard let self = self else { return }

      let activities = self.day.getActivityForDay(
        date: self.calendar.date(from: self.selectedDate)!)

      DispatchQueue.main.async {
        self.updateWithData(activities)
        self.isLoading = false
      }
    }
  }

  private func updateWithData(_ activities: [ActivityEntry]) {
    self.cachedActivities = activities
    self.computeAppUsage()
    let showTimeUnderMinute = UserDefaults.standard.bool(
      forKey: "showTimeUnderMinute", defaultValue: true)
    self.mostUsedApps = self.appUsageDurations.map {
      AppUsage(appName: $0.key, duration: $0.value)
    }
    .sorted { $0.duration > $1.duration }
    .filter {
      showTimeUnderMinute
        || $0.duration > TimeInterval.Datatype(integerLiteral: 60)
    }

    self.calculateDayStats()
    self.precomputeSegmentData()
    self.objectWillChange.send()
  }

  private func precomputeSegmentData() {
    segmentData = (0..<segmentCount).map { segment in
      let isActive = isSegmentActive(segment)
      let apps = appsForSegment(segment)
      let color = colorForSegment(segment, apps: apps)
      return SegmentInfo(isActive: isActive, apps: apps, color: color)
    }
  }

  func endOfDayPosition(width: CGFloat) -> CGFloat {
    let calendar = Calendar.current
    let endOfDayComponents = calendar.dateComponents(
      [.hour, .minute], from: endOfDayTime)
    let totalMinutes =
      (endOfDayComponents.hour ?? 0) * 60 + (endOfDayComponents.minute ?? 0)
    return (CGFloat(totalMinutes) / CGFloat(24 * 60)) * width
  }

  private var endOfDayTime: Date {
    let defaults = UserDefaults.standard
    if let savedTime = defaults.object(forKey: "endOfDayTime") as? Date {
      return savedTime
    } else {
      return Calendar.current.date(from: DateComponents(hour: 4, minute: 0))
        ?? Date()
    }
  }

  var selectedDayStart: Date {
    let calendar = Calendar.current
    let zero = calendar.startOfDay(
      for: calendar.date(from: selectedDate) ?? Date())
    let endOfDayHour = calendar.component(.hour, from: endOfDayTime)
    return calendar.date(byAdding: .hour, value: endOfDayHour, to: zero) ?? zero
  }

  var totalActiveDuration: TimeInterval {
    return appUsageDurations.values.reduce(0, +)
  }

  private var appColors: [String: Color] = [:]

  var isTodaySelected: Bool {
    calendar.isDateInToday(calendar.date(from: selectedDate) ?? Date())
  }

  func changeDate(by days: Int) {
    if var newDate = calendar.date(from: selectedDate) {
      newDate =
        calendar.date(byAdding: .day, value: days, to: newDate) ?? newDate
      if newDate <= Date() {
        selectedDate = calendar.dateComponents(
          [.year, .month, .day], from: newDate)
      }
    }
  }

  func updateHoverPosition(at location: CGPoint, width: CGFloat) {
    hoverPosition = max(0, min(location.x, width))
    let newSegment = segmentForLocation(location, width: width)
    if newSegment != currentHoverSegment {
      currentHoverSegment = newSegment
      if isSegmentActive(newSegment) {
        triggerHapticFeedback()
      }
    }
  }

  func segmentForLocation(_ location: CGPoint, width: CGFloat) -> Int {
    Int((location.x / width) * CGFloat(segmentCount))
  }

  func xPositionForSegment(_ segment: Int, width: CGFloat) -> CGFloat {
    (CGFloat(segment) / CGFloat(segmentCount)) * width
  }

  func timeRangeForSegment(_ segment: Int) -> String {
    let startTime = Calendar.current.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: Calendar.current.startOfDay(for: Date()))!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return
      "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
  }

  private func computeAppUsage() {
    appUsageDurations.removeAll()
    var lastApp: String?
    for activity in cachedActivities {
      if let lastApp = lastApp {
        appUsageDurations[lastApp, default: 0] += Double(Watcher.INTERVAL)
      }
      lastApp = activity.appName
    }
  }

  func isSegmentActive(_ segment: Int) -> Bool {
    let startTime = calendar.date(
      byAdding: .minute, value: segment * segmentDuration, to: selectedDayStart)!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    return cachedActivities.contains {
      $0.timestamp >= startTime && $0.timestamp < endTime
    }
  }

  func calculateActivityRatio(
    appUsages: [AppUsage], segmentDuration: TimeInterval
  ) -> Double {
    let totalDuration = appUsages.reduce(0) { $0 + $1.duration }
    let ratio = totalDuration / segmentDuration
    return min(max(ratio, 0.1), 1)
  }

  func colorForSegment(_ segment: Int, apps: [AppUsage]) -> Color {
    let opacity = calculateActivityRatio(
      appUsages: apps, segmentDuration: TimeInterval(segmentDuration * 60))
    if useColors {
      if let dominantApp = apps.max(by: { $0.duration < $1.duration })?.appName {
        return colorForApp(dominantApp).opacity(opacity)
      }
    }
    return Style.Colors.accent.opacity(0.8)
  }

  func appsForSegment(_ segment: Int) -> [AppUsage] {
    let startTime = calendar.date(
      byAdding: .minute, value: segment * segmentDuration, to: selectedDayStart)!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))

    var appUsage: [String: TimeInterval] = [:]

    for activity in cachedActivities {
      if activity.timestamp >= startTime && activity.timestamp < endTime {
        appUsage[activity.appName, default: 0] += Double(Watcher.INTERVAL)
      } else if activity.timestamp >= endTime {
        break
      }
    }

    let showTimeUnderMinute = UserDefaults.standard.bool(
      forKey: "showTimeUnderMinute", defaultValue: true)

    return appUsage.map { AppUsage(appName: $0.key, duration: $0.value) }
      .filter {
        showTimeUnderMinute
          || $0.duration > TimeInterval.Datatype(integerLiteral: 60)
      }
      .sorted { (app1, app2) -> Bool in
        if Int(app1.duration / 60) == Int(app2.duration / 60) {
          return app1.appName < app2.appName
        } else {
          return app1.duration > app2.duration
        }
      }
  }

  func mergeAdjacentSegments() -> [(Int, Int)] {
    var mergedSegments: [(Int, Int)] = []
    var currentStart: Int?
    guard !segmentData.isEmpty else { return [] }
    for segment in 0..<segmentCount {
      if segmentData[segment].isActive {
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
      mergedSegments.append((start, segmentCount - 1))
    }

    return mergedSegments
  }

  var dateString: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none

    if let date = calendar.date(from: selectedDate) {
      if calendar.isDateInToday(date) {
        return "Today"
      } else if calendar.isDateInYesterday(date) {
        return "Yesterday"
      } else {
        return formatter.string(from: date)
      }
    }
    return "Unknown"
  }

  func hourLabels(for width: CGFloat) -> [Int] {
    width < 500
      ? [0, 6, 12, 18, 24] : stride(from: 0, through: 24, by: 2).map { $0 }
  }

  func hourLabelWidth(for width: CGFloat) -> CGFloat {
    let labels = hourLabels(for: width)
    return width / CGFloat(labels.count - 1)
  }

  func calculateDayStats() {
    let dayStart = selectedDayStart
    let nextDayStart = calendar.date(byAdding: .day, value: 1, to: dayStart)!

    let endOfDayComponents = calendar.dateComponents(
      [.hour, .minute], from: endOfDayTime)
    let endOfDay = calendar.date(
      bySettingHour: endOfDayComponents.hour ?? 4, minute: 0, second: 0,
      of: nextDayStart)!
    let filteredActivities = cachedActivities.filter {
      $0.timestamp <= endOfDay && $0.timestamp >= dayStart
    }
    let (clockIn, clockOut, active) = TimelineUtils.calculateDayStats(
      activities: filteredActivities)
    clockInTime = clockIn
    clockOutTime = clockOut
    activeTime = active
  }

  func formatDuration(_ duration: TimeInterval) -> String {
    return TimelineUtils.formatDuration(duration) ?? ""
  }

}

struct SegmentInfo {
  let isActive: Bool
  let apps: [AppUsage]
  let color: Color
}

extension Array {
  func group<Key: Hashable>(by keyPath: (Element) -> Key) -> [Key: [Element]] {
    return Dictionary(grouping: self, by: keyPath)
  }
}
