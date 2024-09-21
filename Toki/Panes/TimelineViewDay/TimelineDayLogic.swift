//
//  TimelineViewDayLogic.swift
//  Toki
//
//  Created by tnixc on 19/9/2024.
//

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
  private var cache: [DateComponents: [ActivityEntry]] = [:]
  private let queue = DispatchQueue(
    label: "com.toki.dataLoading", qos: .userInitiated)

  func loadData(for dateComponents: DateComponents) {
    isLoading = true

    queue.async { [weak self] in
      guard let self = self else { return }

      if let cachedData = self.cache[dateComponents] {
        self.updateWithData(cachedData)
      } else {
        if let date = self.calendar.date(from: dateComponents) {
          let activities = self.day.getActivityForDay(date: date)
          self.cache[dateComponents] = activities
          self.updateWithData(activities)
        }
      }

      DispatchQueue.main.async {
        self.isLoading = false
      }
    }
  }

  private func updateWithData(_ activities: [ActivityEntry]) {
    DispatchQueue.main.async {
      self.cachedActivities = activities
      self.precomputeSegmentData()
      self.computeAppUsage()
      self.mostUsedApps = self.appUsageDurations.map {
        AppUsage(appName: $0.key, duration: $0.value)
      }
      .sorted { $0.duration > $1.duration }
      self.calculateDayStats()
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

  let calendar = Calendar.current
  let day = Day()

  // Constants
  let timelineHeight: CGFloat = 100
  let segmentDuration: Int = 10
  let segmentCount: Int = 144
  let hoverLineExtension: CGFloat = 10
  private var cachedActivities: [ActivityEntry] = []
  private var activeSegments: Set<Int> = []
  private var segmentDominantApps: [Int: String] = [:]
  private var appUsageDurations: [String: TimeInterval] = [:]

  init() {
    let today = Date()
    self.selectedDate = calendar.dateComponents(
      [.year, .month, .day], from: today)
  }

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
      if !appsForSegment(newSegment).isEmpty {
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

  //  func loadData(for dateComponents: DateComponents) {
  //    if let date = calendar.date(from: dateComponents) {
  //      cachedActivities = day.getActivityForDay(date: date)
  //      precomputeSegmentData()
  //      computeAppUsage()
  //      mostUsedApps = appUsageDurations.map {
  //        AppUsage(appName: $0.key, duration: $0.value)
  //      }
  //      .sorted { $0.duration > $1.duration }
  //    }
  //    calculateDayStats()
  //  }

  private func precomputeSegmentData() {
    activeSegments.removeAll()
    segmentDominantApps.removeAll()

    for segment in 0..<segmentCount {
      let (isActive, dominantApp) = computeSegmentInfo(segment)
      if isActive {
        activeSegments.insert(segment)
        if let app = dominantApp {
          segmentDominantApps[segment] = app
        }
      }
    }
  }

  private func computeSegmentInfo(_ segment: Int) -> (Bool, String?) {
    let startTime = calendar.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: calendar.startOfDay(for: selectedDayStart))!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))

    var isActive = false
    var appUsage: [String: TimeInterval] = [:]

    for activity in cachedActivities {
      if activity.timestamp >= startTime && activity.timestamp < endTime {
        isActive = true
        let duration = min(
          endTime.timeIntervalSince(activity.timestamp),
          TimeInterval(segmentDuration * 60))
        appUsage[activity.appName, default: 0] += duration
      } else if activity.timestamp >= endTime {
        break
      }
    }

    let dominantApp = appUsage.max(by: { $0.value < $1.value })?.key
    return (isActive, dominantApp)
  }

  private func computeAppUsage() {
    appUsageDurations.removeAll()
    var lastApp: String?

    for activity in cachedActivities {
      if let lastApp = lastApp {
        appUsageDurations[lastApp, default: 0] += Double(Watcher().INTERVAL)
      }
      lastApp = activity.appName
    }
  }

  func isSegmentActive(_ segment: Int) -> Bool {
    return activeSegments.contains(segment)
  }

  func colorForSegment(_ segment: Int) -> Color {
    if SettingsManager.shared.bool(forKey: "showAppColors"),
      let dominantApp = segmentDominantApps[segment]
    {
      return colorForApp(dominantApp)
    } else {
      return Color.accentColor.opacity(0.8)
    }
  }

  func appsForSegment(_ segment: Int) -> [AppUsage] {
    let startTime = calendar.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: calendar.startOfDay(for: selectedDayStart))!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))

    var appUsage: [String: TimeInterval] = [:]

    for activity in cachedActivities {
      if activity.timestamp >= startTime && activity.timestamp < endTime {
        appUsage[activity.appName, default: 0] += Double(Watcher().INTERVAL)
      } else if activity.timestamp >= endTime {
        break
      }
    }

    return appUsage.map { AppUsage(appName: $0.key, duration: $0.value) }
      .sorted { (app1, app2) -> Bool in
        if Int(app1.duration / 60) == Int(app2.duration / 60) {
          return app1.appName < app2.appName
        } else {
          return app1.duration > app2.duration
        }
      }
  }

  func formatDuration(_ duration: TimeInterval) -> String {
    if duration < 60 {
      return "<1m"
    }
    let minutes = Int(duration) / 60
    if minutes > 59 {
      let hours = minutes / 60
      let remainingMinutes = minutes % 60

      return "\(hours)h \(remainingMinutes)m"
    }
    return "\(minutes)m"
  }

  func mergeAdjacentSegments() -> [(Int, Int)] {
    var mergedSegments: [(Int, Int)] = []
    var currentStart: Int?

    for segment in 0..<segmentCount {
      if isSegmentActive(segment) {
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
  func colorForApp(_ appName: String) -> Color {
    let hash = appName.unicodeScalars.reduce(0) { $0 + $1.value }
    let index = Int(hash) % Int(colorSet.count)
    return colorSet[Int(index)]
  }

  func dominantAppForSegment(_ segment: Int) -> String? {
    let apps = appsForSegment(segment)
    return apps.max(by: { $0.duration < $1.duration })?.appName
  }

  func calculateDayStats() {
    let dayStart = selectedDayStart
    let nextDayStart = calendar.date(byAdding: .day, value: 1, to: dayStart)!

    let endOfDayComponents = calendar.dateComponents(
      [.hour, .minute], from: endOfDayTime)
    let endOfDay = calendar.date(
      bySettingHour: endOfDayComponents.hour ?? 4,
      minute: endOfDayComponents.minute ?? 0,
      second: 0,
      of: nextDayStart)!

    let filteredActivities =
      cachedActivities
      .filter { $0.timestamp <= endOfDay }
      .filter { $0.timestamp >= dayStart }

    clockInTime = filteredActivities.first?.timestamp
    clockOutTime = filteredActivities.last?.timestamp

    activeTime = 0
    for entry in appUsageDurations {
      activeTime += entry.value
    }

  }

}
extension Array {
  func group<Key: Hashable>(by keyPath: (Element) -> Key) -> [Key: [Element]] {
    return Dictionary(grouping: self, by: keyPath)
  }
}
