import Foundation
import SwiftUI

func triggerHapticFeedback() {
  NSHapticFeedbackManager.defaultPerformer.perform(
    .levelChange, performanceTime: .default)
}

func formatDate(components: DateComponents) -> String {
  guard let date = Calendar.current.date(from: components) else {
    return "Invalid date"
  }

  let today = Calendar.current.startOfDay(for: Date())
  let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

  if Calendar.current.isDate(date, inSameDayAs: today) {
    return "Today"
  } else if Calendar.current.isDate(date, inSameDayAs: yesterday) {
    return "Yesterday"
  } else {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.string(from: date)
  }
}
