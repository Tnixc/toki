//
//  KeyPressHandler.swift
//  Toki
//
//  Created by tnixc on 28/9/2024.
//

import Combine
import SwiftUI

class KeyPressHandler: ObservableObject {
  @Published var isCommandKeyHeld = false
  private var commandKeyTimer: Timer?

  static func handleKeyPress(
    key: String, selectedViewType: Binding<TimelineViewType>
  ) {
    switch key {
    case "1":
      withAnimation {
        selectedViewType.wrappedValue = .day
      }
    case "2":
      withAnimation {
        selectedViewType.wrappedValue = .week
      }
    case "3":
      withAnimation {
        selectedViewType.wrappedValue = .month
      }
    default:
      break
    }
  }

  func startCommandKeyTimer() {
    commandKeyTimer = Timer.scheduledTimer(
      withTimeInterval: 0.5, repeats: false
    ) { [weak self] _ in
      withAnimation(.spring(duration: 0.3)) {
        self?.isCommandKeyHeld = true
      }
    }
  }

  func stopCommandKeyTimer() {
    commandKeyTimer?.invalidate()
    commandKeyTimer = nil
    withAnimation(.spring(duration: 0.3)) {
      isCommandKeyHeld = false
    }
  }
}
