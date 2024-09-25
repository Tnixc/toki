import SwiftUI

enum TimelineViewType: String, CaseIterable {
  case day = "Day"
  case week = "Week"
  case month = "Month"
}

struct TimelineViewSelector: View {
  @Binding var selectedViewType: TimelineViewType
  @State private var isExpanded = false
  @State private var isButtonEnabled = true

  static let width = 120.0
  static let itemHeight = 30.0

  var body: some View {
    ZStack(alignment: .top) {
      if isExpanded {
        selectionButton.hoverEffect()
        dropdownMenu
      } else {
        selectionButton.hoverEffect()
      }
    }
    .zIndex(isExpanded ? 50 : -10)
    .onAppear {
      setupMouseEventMonitor()
    }
  }

  // MARK: - UI Components

  private var selectionButton: some View {
    Button(action: toggleExpanded) {
      HStack {
        Text(selectedViewType.rawValue)
          .fontWeight(.medium)
        Spacer()
        Image(systemName: "chevron.down")
          .foregroundColor(.secondary)
          .fontWeight(.bold)
      }
      .padding()
      .frame(width: TimelineViewSelector.width, height: Style.Colors.Button.height)
      .background(Style.Colors.Button.bg)
      .clipShape(
        RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius))
    }
    .buttonStyle(.plain)
    .overlay(
      RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius)
        .stroke(
          Style.Colors.Button.border, lineWidth: Style.Colors.Layout.borderWidth
        )
    )
  }

  private var dropdownMenu: some View {
    VStack(alignment: .leading, spacing: 2) {
      ForEach(TimelineViewType.allCases, id: \.self) { viewType in
        dropdownMenuItem(for: viewType)
      }
    }
    .padding(2)
    .background(.thickMaterial)
    .background(Style.Colors.Button.bg)
    .overlay(
      RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius + 2)
        .stroke(Color.primary.opacity(0.2), lineWidth: 2)
    )
    .clipShape(
      RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius + 2)
    )
    .frame(width: TimelineViewSelector.width)
    .offset(y: 75)
    .transition(.blurReplace)
    .zIndex(50)
    .frame(maxHeight: Style.Colors.Button.height).fixedSize(
      horizontal: true, vertical: true
    )
    .shadow(color: Color.black.opacity(0.1), radius: 9)
  }

  private func dropdownMenuItem(for viewType: TimelineViewType) -> some View {
    Button(action: { selectViewType(viewType) }) {
      HStack {
        Image(systemName: "checkmark")
          .scaleEffect(1, anchor: .center)
          .foregroundColor(selectedViewType == viewType ? .primary : .clear)
          .fontWeight(.medium)
          .frame(width: 15)
          .padding(.leading, Style.Colors.Layout.padding)
        Text(viewType.rawValue)
          .foregroundColor(.primary)
          .padding(.vertical)
          .frame(height: TimelineViewSelector.itemHeight)
          .frame(maxWidth: .infinity, alignment: .leading)
          .clipShape(
            RoundedRectangle(cornerRadius: Style.Colors.Layout.cornerRadius))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .hoverEffect()
    .buttonStyle(.borderless)
    .frame(height: TimelineViewSelector.itemHeight)
  }

  // MARK: - Helper Functions

  private func toggleExpanded() {
    guard isButtonEnabled else { return }

    withAnimation(.smooth(duration: 0.15)) {
      isExpanded.toggle()
    }

    isButtonEnabled = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      isButtonEnabled = true
    }
  }

  private func selectViewType(_ viewType: TimelineViewType) {
    self.selectedViewType = viewType
    toggleExpanded()
  }

  private func setupMouseEventMonitor() {
    NSEvent.addLocalMonitorForEvents(matching: [
      .leftMouseUp, .rightMouseUp,
    ]) { event in
      if isExpanded {
        DispatchQueue.main.async {
          toggleExpanded()
        }
      }
      return event
    }
  }
}
