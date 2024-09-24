import SwiftUI

struct SettingItem<Content: View>: View {
  let title: String
  let description: String
  let icon: String
  let content: () -> Content
  var body: some View {
    HStack(spacing: 5) {
      Image(systemName: icon).renderingMode(.template).font(.title3).frame(
        width: 30, height: 30)
      VStack(alignment: .leading) {
        Text(title)
        Text(description).font(.caption).foregroundStyle(.secondary)
          .multilineTextAlignment(.leading)
      }
      Spacer()
      content()
    }

    .padding(10)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
    )
    .background(Color.secondary.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

struct SettingItemRow<Content: View>: View {
  let title: String
  let description: String
  let icon: String
  let content: () -> Content
  var body: some View {
    HStack(spacing: 5) {
      Image(systemName: icon).renderingMode(.template).font(.title3).frame(
        width: 30, height: 30)
      VStack(alignment: .leading) {
        Text(title)
        Text(description).font(.caption).foregroundStyle(.secondary)
          .multilineTextAlignment(.leading)
      }
      Spacer()
      content()
    }
  }
}

struct SettingItemGroup<Content: View>: View {
  let content: () -> Content
  var body: some View {
    content()
      .padding(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
      )
      .background(Color.secondary.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}
