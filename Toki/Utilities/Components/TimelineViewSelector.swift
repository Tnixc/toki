import SwiftUI

// Enum representing different timeline view types
enum TimelineViewType: String, CaseIterable {
  case day = "Day"
  case week = "Week"
  case month = "Month"
}

struct TimelineViewSelector: View {
  @Binding var selectedViewType: TimelineViewType
  @State private var isExpanded = false

  var body: some View {
    ZStack(alignment: .top) {
      if isExpanded {
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

  // Button to toggle dropdown expansion
  private var selectionButton: some View {
    Button(action: toggleExpanded) {
      HStack {
        Text(selectedViewType.rawValue)
          .fontWeight(.medium)
        Spacer()
        Image(systemName: "chevron.down")
          .foregroundColor(.secondary)
          .fontWeight(.bold)
          .rotationEffect(.degrees(isExpanded ? 180 : 0))
      }
      .padding()
      .frame(width: 120, height: 40)
      .background(Color.secondary.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .buttonStyle(.plain)
    .overlay(
      RoundedRectangle(cornerRadius: 10).stroke(
        Color.secondary.opacity(0.2), lineWidth: 1))
  }

  // Dropdown menu showing view type options
  private var dropdownMenu: some View {
    VStack(alignment: .leading, spacing: 2) {
      ForEach(TimelineViewType.allCases, id: \.self) { viewType in
        dropdownMenuItem(for: viewType)
      }
    }
    .padding(2)
    .background(.ultraThinMaterial)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.primary.opacity(0.2), lineWidth: 2)
    )
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .frame(width: 120)
    .offset(y: 30)
    .transition(.blurReplace)
    .zIndex(50)
    .frame(maxHeight: 40).fixedSize(horizontal: true, vertical: true)
    .shadow(color: Color.black.opacity(0.1), radius: 9)
  }

  // Individual dropdown menu item
  private func dropdownMenuItem(for viewType: TimelineViewType) -> some View {
    Button(action: { selectViewType(viewType) }) {
      HStack {
        Image(systemName: "checkmark")
          .scaleEffect(1, anchor: .center)
          .foregroundColor(selectedViewType == viewType ? .primary : .clear)
          .fontWeight(.medium)
          .frame(width: 15)
          .padding(.leading, 10)
        Text(viewType.rawValue)
          .foregroundColor(.primary)
          .padding(.vertical)
          .frame(height: 30)
          .frame(maxWidth: .infinity, alignment: .leading)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .hoverEffect()
    .buttonStyle(.borderless)
    .frame(height: 30)
  }

  // MARK: - Helper Functions

  // Toggle dropdown expansion state
  private func toggleExpanded() {
    withAnimation(
      .easeOut(duration: 0.1)
    ) {
      isExpanded.toggle()
    }
  }

  // Select a view type and close dropdown
  private func selectViewType(_ viewType: TimelineViewType) {
    self.selectedViewType = viewType
    toggleExpanded()
  }

  // Setup mouse event monitoring to close dropdown when clicking outside
  private func setupMouseEventMonitor() {
    NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) {
      event in
      if isExpanded {
        let locationInWindow = event.locationInWindow
        let frame =
          NSApp.windows.first?.contentView?.convert(
            NSRect(x: 0, y: 0, width: 120, height: 200), to: nil) ?? .zero

        if !frame.contains(locationInWindow) {
          DispatchQueue.main.async {
            toggleExpanded()
          }
        }
      }
      return event
    }
  }
}

struct ContentView: View {
  @State private var selectedViewType: TimelineViewType = .day

  var body: some View {
    ZStack {
      VStack {
        Spacer()
        TimelineViewSelector(selectedViewType: $selectedViewType)
          .frame(maxHeight: 40)
          .fixedSize(horizontal: true, vertical: true)
        Spacer()
      }
    }
  }
}
