import SwiftUI

enum Style {
  // MARK: - Colors
  enum Colors {

    // MARK: - Layout
    enum Layout {
      static let cornerRadius: CGFloat = 10
      static let padding: CGFloat = 10
      static let smallPadding: CGFloat = 5
      static let borderWidth: CGFloat = 1
    }

    // MARK: - Buttons
    enum Button {
      static let height: CGFloat = 40
      static let smallHeight: CGFloat = 36
    }

    // MARK: - Icons
    enum Icon {
      static let size: CGFloat = 20
      static let smallSize: CGFloat = 14
    }

    // MARK: - Timeline
    enum Timeline {
      static let background = Color.accentColor.opacity(0.1)
      static let border = Color.accentColor.opacity(0.3)
    }

    // MARK: - Most Used Apps
    enum MostUsedApps {
      static let background = Color.secondary.opacity(0.1)
      static let border = Color.secondary.opacity(0.2)
    }

    // MARK: - Settings
    enum Settings {
      static let itemBackground = Color.secondary.opacity(0.1)
      static let itemBorder = Color.secondary.opacity(0.2)
    }
  }
}
