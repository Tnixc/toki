import SwiftUI

struct CustomButton: View {
  let action: () -> Void
  let label: String
  let icon: String?
  let width: CGFloat?
  let height: CGFloat?
  let align: Alignment?

  init(
    action: @escaping () -> Void,
    label: String,
    icon: String? = nil,
    width: CGFloat? = nil,
    height: CGFloat? = nil,
    align: Alignment? = nil
  ) {
    self.action = action
    self.label = label
    self.icon = icon
    self.width = width
    self.height = height
    self.align = align
  }

  var body: some View {
    Button(action: action) {
      HStack {
        if align == .trailing {
          Spacer()
        }
        if let icon = icon {
          Image(systemName: icon)
            .font(.system(size: Style.Colors.Icon.size))
        }
        if !label.isEmpty {
          Text(label)
        }
        if align == .leading {
          Spacer()
        }
      }
      .padding(Style.Colors.Layout.padding)
      .frame(width: width, height: height ?? Style.Colors.Button.height)
      .background(Style.Colors.Settings.itembg)
      .clipShape(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
      )
      .contentShape(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
      )
      .overlay(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
          .stroke(
            Style.Colors.Settings.itemBorder,
            lineWidth: Style.Colors.Layout.borderWidth)
      )
    }
    .buttonStyle(.plain)
    .hoverEffect()
  }
}

struct CustomButtonPlain: View {
  let action: () -> Void
  let label: String
  let icon: String?
  let width: CGFloat?
  let height: CGFloat?
  let align: Alignment?

  init(
    action: @escaping () -> Void,
    label: String,
    icon: String? = nil,
    width: CGFloat? = nil,
    height: CGFloat? = nil,
    align: Alignment? = nil
  ) {
    self.action = action
    self.label = label
    self.icon = icon
    self.width = width
    self.height = height
    self.align = align
  }

  var body: some View {
    Button(action: action) {
      HStack {
        if align == .trailing {
          Spacer()
        }
        if let icon = icon {
          Image(systemName: icon)
            .font(.system(size: Style.Colors.Icon.size))
        }
        if !label.isEmpty {
          Text(label)
        }
        if align == .leading {
          Spacer()
        }
      }
      .padding(Style.Colors.Layout.padding)
      .frame(width: width, height: height ?? Style.Colors.Button.height)
      .background(.clear)
      .contentShape(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
      )
      .clipShape(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
      )
      .overlay(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
          .fill(.clear)
      )
    }
    .buttonStyle(.plain)
    .hoverEffect()
  }
}
