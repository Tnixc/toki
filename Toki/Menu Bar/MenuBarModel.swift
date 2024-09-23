import Combine
import SwiftUI

class MenuBarModel: ObservableObject {
  @Published var activeDuration: String = "0m"
  @Published var clockInTime: Date?
  @Published var clockOutTime: Date?

  private var timer: Timer?
  private let day = Day()

  init() {
    updateStats()
    startTimer()
  }

  private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) {
      [weak self] _ in
      self?.updateStats()
    }
  }

  func updateStats() {
    let today = Date()
    let activities = day.getActivityForDay(date: today)
    let (clockIn, clockOut, activeTime) = TimelineUtils.calculateDayStats(
      activities: activities)

    DispatchQueue.main.async {
      self.activeDuration = TimelineUtils.formatDuration(activeTime) ?? "N/A"
      self.clockInTime = clockIn
      self.clockOutTime = clockOut
    }
  }
}
