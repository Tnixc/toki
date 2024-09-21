//
//  InfoBox.swift
//  Toki
//
//  Created by tnixc on 21/9/2024.
//

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
  }
}
