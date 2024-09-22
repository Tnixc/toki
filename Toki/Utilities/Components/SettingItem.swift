import SwiftUI

//
//  SettingItem.swift
//  Toki
//
//  Created by tnixc on 21/9/2024.
//

struct SettingItem<Content: View>: View {
  let title: String
  let description: String
  let icon: String
  let content: () -> Content
  var body: some View {
    VStack {
      HStack(spacing: 5) {
        Image(systemName: icon).renderingMode(.template).font(.title3).frame(
          width: 30, height: 30)
        VStack(alignment: .leading) {
          Text(title)
          Text(description).font(.caption).foregroundStyle(.secondary)
        }
        Spacer()
        content()
      }
    }
    .padding(10)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
    )
    .background(Color.secondary.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

struct SettingItemTall<Content: View>: View {
  let title: String
  let description: String
  let icon: String
  let content: () -> Content
  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 5) {
        Image(systemName: icon).renderingMode(.template).font(.title3).frame(
          width: 30, height: 30)
        VStack(alignment: .leading) {
          Text(title)
          Text(description).font(.caption).foregroundStyle(.secondary)
        }
        Spacer()
      }
      content()
    }
    .padding(10)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
    )
    .background(Color.secondary.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
