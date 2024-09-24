import SwiftUI

struct InfoBox<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding()
      .background(Color.secondary.opacity(0.1))
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10).stroke(
          .secondary.opacity(0.2), lineWidth: 1)
      )
  }
}
