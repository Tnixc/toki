import SwiftUI
import UserNotifications

struct MainView: View {
  @State private var selectedViewType: TimelineViewType = .day
  init() {
    requestNotificationPermissions()
  }

  var body: some View {
    ScrollView {
      switch selectedViewType {
      case .day:
        TimelineDay(selectedViewType: $selectedViewType)
      case .week:
        TimelineWeek(selectedViewType: $selectedViewType)
      case .month:
        Text("month")
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  private func requestNotificationPermissions() {
    UNUserNotificationCenter.current().requestAuthorization(options: [
      .alert, .sound, .badge,
    ]) { granted, error in
      if granted {
        print("Notification permission granted")
      } else if let error = error {
        print(
          "Error requesting notification permission: \(error.localizedDescription)"
        )
      }
    }
  }
}
