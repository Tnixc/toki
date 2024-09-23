//
//  TimelineUtils.swift
//  Toki
//
//  Created by tnixc on 21/9/2024.
//

import Foundation

struct TimelineUtils {
  static func formatDuration(_ duration: TimeInterval) -> String? {
    if duration == 0 {
      return nil
    }
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

  static func calculateDayStats(activities: [ActivityEntry]) -> (
    Date?, Date?, TimeInterval
  ) {
    let clockInTime = activities.first?.timestamp
    let clockOutTime = activities.last?.timestamp

    var activeTime: TimeInterval = 0
    if activities.count > 1 {
      for _ in activities {
        activeTime += Double(Watcher.INTERVAL)
      }
    }

    return (clockInTime, clockOutTime, activeTime)
  }
}
