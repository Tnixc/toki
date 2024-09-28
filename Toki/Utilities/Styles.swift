// styles.swift
import SwiftUI

func colorForApp(_ appName: String) -> Color {
  let hash = appName.unicodeScalars.reduce(0) { $0 + $1.value }
  let index = Int(hash) % Int(colorSet.count)
  return colorSet[Int(index)]
}

enum Style {
  enum Colors {
    static let accent: Color = Color.init(hex: "#6EA3FE")
  }

  enum Layout {
    static let cornerRadius: CGFloat = 10
    static let padding: CGFloat = 10
    static let paddingSM: CGFloat = 5
    static let borderWidth: CGFloat = 1
  }

  enum Button {
    static let height: CGFloat = 40
    static let heightSM: CGFloat = 36
    static let heightXS: CGFloat = 24
    static let bg = Color.secondary.opacity(
      0.1
    )
    static let border = Color.secondary.opacity(0.3)
  }

  enum Icon {
    static let size: CGFloat = 20
    static let sizeSM: CGFloat = 14
  }

  enum Timeline {
    static let bg = Colors.accent.opacity(0.1)
    static let border = Colors.accent.opacity(0.3)
  }

  enum Box {
    static let bg = Color.secondary.opacity(0.1)
    static let border = Color.secondary.opacity(0.2)
  }

  enum Settings {
    static let itembg = Color.secondary.opacity(0.1)
    static let itemBorder = Color.secondary.opacity(0.2)
  }
}
