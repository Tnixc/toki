//
//  TimelineViewDayLogic.swift
//  Toki
//
//  Created by tnixc on 19/9/2024.
//

import SwiftUI

class TimelineViewDayLogic: ObservableObject {

  @Published var activities: [MinuteActivity] = []
  @Published var hoveredSegment: Int? = nil
  @Published var isHovering: Bool = false
  @Published var hoverPosition: CGFloat = 0
  @Published var selectedDate: DateComponents
  @Published var showDatePicker = false
  @Published var currentHoverSegment: Int?
  @Published var mostUsedApps: [AppUsage] = []
  @Published var showAppColors: Bool {
    didSet {
      SettingsManager.shared.set(showAppColors, forKey: "showAppColors")
    }
  }

  private var appColors: [String: Color] = [:]

  let calendar = Calendar.current
  let day = Day()

  // Constants
  let timelineHeight: CGFloat = 100
  let segmentDuration: Int = 10
  let segmentCount: Int = 144
  let hoverLineExtension: CGFloat = 10

  init() {
    let today = Date()
    self.selectedDate = calendar.dateComponents(
      [.year, .month, .day], from: today)
    self.showAppColors = SettingsManager.shared.bool(forKey: "showAppColors")
  }

  var selectedDayStart: Date {
    calendar.startOfDay(for: calendar.date(from: selectedDate) ?? Date())
  }

  func loadData(for dateComponents: DateComponents) {
    if let date = calendar.date(from: dateComponents) {
      activities = day.getActivityForDay(date: date)
      mostUsedApps = day.getMostUsedApps(for: date)
    }
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

  func appsForSegment(_ segment: Int) -> [AppUsage] {
    let startTime = calendar.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: selectedDayStart
    )!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    let segmentActivities = activities.filter {
      $0.minute >= startTime && $0.minute < endTime
    }

    let appUsage =
      segmentActivities
      .filter { !$0.isIdle }
      .group(by: { $0.appName })
      .mapValues { activities in
        activities.count * 60
      }

    let v = appUsage.map { AppUsage(appName: $0.key, duration: TimeInterval($0.value)) }
      .sorted { (usage1, usage2) -> Bool in
        if usage1.duration == usage2.duration {
          return usage1.appName < usage2.appName  // Sort alphabetically if durations are equal
        }
        return usage1.duration > usage2.duration  // Sort by duration (descending) otherwise
      }
    return v
  }

  func formatDuration(_ duration: TimeInterval) -> String {
    if duration < 60 {
      return "<1 min"
    }
    let minutes = Int(duration) / 60
    if minutes > 59 {
      let hours = minutes / 60
      let remainingMinutes = minutes % 60
      return "\(hours)h \(remainingMinutes)m"
    }
    return "\(minutes) min"
  }

  func isSegmentActive(_ segment: Int) -> Bool {
    let startTime = calendar.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: selectedDayStart
    )!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    let segmentActivities = activities.filter {
      $0.minute >= startTime && $0.minute < endTime
    }
    let isActive = segmentActivities.contains { !$0.isIdle }
    return isActive
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

  func colorForSegment(_ segment: Int) -> Color {
    if showAppColors, let dominantApp = dominantAppForSegment(segment) {
      return colorForApp(dominantApp)
    } else {
      return Color.accentColor.opacity(0.8)
    }
  }

  func dominantAppForSegment(_ segment: Int) -> String? {
    let apps = appsForSegment(segment)
    return apps.max(by: { $0.duration < $1.duration })?.appName
  }

}
extension Array {
  func group<Key: Hashable>(by keyPath: (Element) -> Key) -> [Key: [Element]] {
    return Dictionary(grouping: self, by: keyPath)
  }
}
