import SwiftUI
import UserNotifications

struct MainView: View {
  @State private var selectedViewType: TimelineViewType = .day
  @StateObject private var keyPressHandler = KeyPressHandler()

  init() {
    requestNotificationPermissions()
  }

  var body: some View {
    ZStack {
      ScrollView {
        switch selectedViewType {
        case .day:
          TimelineDay(selectedViewType: $selectedViewType)
            .transition(
              .blurReplace.combined(with: .opacity).combined(
                with: .scale(0.9, anchor: .center))
            )
        case .week:
          Text("Week view not implemented yet. Press 1 to go back to day view.")
            .frame(minWidth: 650)
            .transition(
              .blurReplace.combined(with: .opacity).combined(
                with: .scale(0.9, anchor: .center))
            )
        case .month:
          Text(
            "Month view not implemented yet. Press 1 to go back to day view."
          ).frame(minWidth: 650)
            .transition(
              .blurReplace.combined(with: .opacity).combined(
                with: .scale(0.9, anchor: .center))
            )

        }
      }
      .animation(.smooth(duration: 0.3), value: selectedViewType)
      .frame(maxWidth: 650, maxHeight: .infinity)
      VStack {
        Spacer()
        if keyPressHandler.isCommandKeyHeld {
          FloatingView(isVisible: keyPressHandler.isCommandKeyHeld)
        }
      }
    }
    .onAppear {
      setupKeyEventMonitoring()
    }
  }

  private func setupKeyEventMonitoring() {
    NSEvent.addLocalMonitorForEvents(matching: [
      .keyDown, .keyUp, .flagsChanged,
    ]) { event in
      switch event.type {
      case .keyDown:
        KeyPressHandler.handleKeyPress(
          event: event,
          selectedViewType: $selectedViewType
        )
      case .flagsChanged:
        if event.modifierFlags.contains(.command) {
          keyPressHandler.startCommandKeyTimer()
        } else {
          keyPressHandler.stopCommandKeyTimer()
        }
      default:
        break
      }
      return event
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
