// InfoBox.swift

import SwiftUI

struct InfoBox<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding(Style.Colors.Layout.padding)
      .background(Style.Colors.MostUsedApps.bg)
      .cornerRadius(Style.Colors.Layout.cornerRadius)
      .overlay(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
          .stroke(
            Style.Colors.MostUsedApps.border,
            lineWidth: Style.Colors.Layout.borderWidth)
      )
  }
}
