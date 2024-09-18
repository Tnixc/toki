import SwiftUI

// MARK: - Always on Top

/// Set this view as a background on e.g. the main view.

struct AlwaysOnTop: View {
    static let settingsKey = "window.setting.isAlwaysOnTop"
    @SceneStorage(Self.settingsKey) var isAlwaysOnTop: Bool = false

    var body: some View {
        EmptyView()
            .onChange(of: isAlwaysOnTop) { newValue in
                guard let window = NSApp.windows.first else { return }
                window.level = newValue ? .floating : .normal
            }
    }
}

// MARK: - Always on Top Command

struct AlwaysOnTopCommand: Commands {

  var body: some Commands {
    CommandGroup(after: .windowArrangement) {
      // There is a SwiftUI bug that keeps the checkmark from updating.
      AlwaysOnTopCheckbox("Toggle Always on Top")
    }
  }
}

// MARK: - Always on Top Checkbox

struct AlwaysOnTopCheckbox: View {

  let title: LocalizedStringKey

  @AppStorage(AlwaysOnTop.settingsKey) var isAlwaysOnTop: Bool = false

  init(_ title: LocalizedStringKey = "Always on top") {
    self.title = title
  }

  var body: some View {
    Toggle(title, isOn: $isAlwaysOnTop)
      .toggleStyle(CheckboxToggleStyle())
  }
}

// MARK: - Preview

struct AlwaysOnTopCheckbox_Previews: PreviewProvider {
  static var previews: some View {
    AlwaysOnTopCheckbox()
  }
}
