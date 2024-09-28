//
//  Constants.swift
//  Toki
//
//  Created by tnixc on 24/9/2024.
//

import Foundation

enum Constants {
  static let interval = 6
  static let idleTime = 60
  static let defaultClockOutHour = 18
  static let defaultClockOutMinute = 0
  static let defaultReminderInterval = 15
  static let segmentCount = 144
  static let segmentDuration = 10
  static let overlayDismissTime: TimeInterval = 5.0
  static let dbFileName = "activities.sqlite3"

  enum TimelineDay {
    static let timelineHeight: CGFloat = 95
    static let hoverLineExtension: CGFloat = 10
  }

  enum TimelineWeek {
    static let displayedHours = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]
  }

  enum Settings {
    static let windowWidth: CGFloat = 700
    static let windowHeight: CGFloat = 600
  }

  enum DatePicker {
    static let width: CGFloat = 300
    static let height: CGFloat = 350
  }
}
