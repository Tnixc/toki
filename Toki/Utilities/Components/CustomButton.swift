import SwiftUI

struct CustomButton: View {
  let action: () -> Void
  let label: String
  let icon: String?
  let width: CGFloat?
  let height: CGFloat?

  init(
    action: @escaping () -> Void, label: String, icon: String? = nil,
    width: CGFloat? = nil, height: CGFloat? = nil
  ) {
    self.action = action
    self.label = label
    self.icon = icon
    self.width = width
    self.height = height
  }

  var body: some View {
    Button(action: action) {
      HStack {
        if let icon = icon {
          Image(systemName: icon)
            .fontWeight(.bold)
        }
        if !label.isEmpty {
          Text(label)
            .fontWeight(.medium)
        }
      }
      .padding()
      .frame(width: width, height: height)
      .background(Color.secondary.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
    .hoverEffect()
  }
}
