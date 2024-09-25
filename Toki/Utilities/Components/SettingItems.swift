import SwiftUI

struct SettingItem<Content: View>: View {
  let title: String
  let description: String
  let icon: String
  let content: () -> Content

  var body: some View {
    HStack(spacing: Style.Colors.Layout.paddingSM) {
      Image(systemName: icon)
        .renderingMode(.template)
        .font(.title3)
        .frame(width: Style.Colors.Icon.size, height: Style.Colors.Icon.size)
      VStack(alignment: .leading) {
        Text(title)
        Text(description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.leading)
      }
      Spacer()
      content()
    }
    .padding(Style.Colors.Layout.padding)
    .overlay(
      RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
        .stroke(
          Style.Colors.Settings.itemBorder,
          lineWidth: Style.Colors.Layout.borderWidth)
    )
    .background(Style.Colors.Settings.itembg)
    .clipShape(RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius))
  }
}

struct SettingItemRow<Content: View>: View {
  let title: String
  let description: String
  let icon: String
  let content: () -> Content

  var body: some View {
    HStack(spacing: Style.Colors.Layout.paddingSM) {
      Image(systemName: icon)
        .renderingMode(.template)
        .font(.title3)
        .frame(width: Style.Colors.Icon.size, height: Style.Colors.Icon.size)
      VStack(alignment: .leading) {
        Text(title)
        Text(description)
          .font(.caption)
          .foregroundStyle(.secondary)
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
      .padding(Style.Colors.Layout.padding)
      .overlay(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
          .stroke(
            Style.Colors.Settings.itemBorder,
            lineWidth: Style.Colors.Layout.borderWidth)
      )
      .background(Style.Colors.Settings.itembg)
      .clipShape(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius))
  }
}
