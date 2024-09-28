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
            .transition(.offset(y: 40).combined(with: .opacity))
        case .week:
          TimelineWeek(selectedViewType: $selectedViewType)
            .transition(.offset(y: 40).combined(with: .opacity))
        case .month:
          Text("Month view not implemented yet")
            .transition(.offset(y: 40).combined(with: .opacity))
            .padding()
        }
      }
      .frame(maxWidth: 650, maxHeight: .infinity)
      .animation(.smooth(duration: 0.3), value: selectedViewType)
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
        if let key = event.charactersIgnoringModifiers {
          KeyPressHandler.handleKeyPress(
            key: key, selectedViewType: $selectedViewType)
        }
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
