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
        Text("Month view not implemented yet")
          .padding()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onAppear {
      NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
        switch event.charactersIgnoringModifiers {
        case "1":
          selectedViewType = .day
          return nil
        case "2":
          selectedViewType = .week
          return nil
        case "3":
          selectedViewType = .month
          return nil
        default:
          break
        }
        return event
      }
    }
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
