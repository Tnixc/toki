// styles.swift
import SwiftUI

enum Style {
  // MARK: - Layout
  enum Layout {
    static let cornerRadius: CGFloat = 10
    static let padding: CGFloat = 10
    static let paddingSM: CGFloat = 5
    static let borderWidth: CGFloat = 1
  }

  // MARK: - Buttons
  enum Button {
    static let height: CGFloat = 40
    static let heightSM: CGFloat = 36
    static let heightXS: CGFloat = 24
    static let bg = Color.secondary.opacity(
      0.1
    )
    static let border = Color.secondary.opacity(0.3)
  }

  // MARK: - Icons
  enum Icon {
    static let size: CGFloat = 20
    static let sizeSM: CGFloat = 14
  }

  // MARK: - Timeline
  enum Timeline {
    static let bg = Color.accentColor.opacity(0.1)
    static let border = Color.accentColor.opacity(0.3)
  }

  // MARK: - Most Used Apps
  enum Box {
    static let bg = Color.secondary.opacity(0.1)
    static let border = Color.secondary.opacity(0.2)
  }

  // MARK: - Settings
  enum Settings {
    static let itembg = Color.secondary.opacity(0.1)
    static let itemBorder = Color.secondary.opacity(0.2)
  }

}
