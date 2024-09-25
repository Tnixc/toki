// InfoBox.swift

import SwiftUI

struct InfoBox<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding(Style.Layout.padding)
      .background(Style.MostUsedApps.bg)
      .cornerRadius(Style.Layout.cornerRadius)
      .overlay(
        RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
          .stroke(
            Style.MostUsedApps.border,
            lineWidth: Style.Layout.borderWidth)
      )
  }
}
