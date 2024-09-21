import SwiftUI

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
      Button(action: {
        toggleExpanded()
      }) {
        HStack {
          Text(selectedViewType.rawValue)
            .foregroundColor(.secondary)
            .fontWeight(.bold)
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

      if isExpanded {
        VStack(alignment: .leading, spacing: 2) {
          ForEach(TimelineViewType.allCases, id: \.self) { viewType in
            Button(action: {
              self.selectedViewType = viewType
              toggleExpanded()
            }) {
              Text(viewType.rawValue)
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            .frame(height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(viewType == selectedViewType ? Color.blue : Color.clear)
          }
        }
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 120)
        .offset(y: 40)
        .transition(.blurReplace.combined(with: .opacity))
        .zIndex(50)
        .frame(maxHeight: 40).fixedSize(horizontal: true, vertical: true)
        .shadow(color: Color.black.opacity(0.1), radius: 9)
      }
    }
    .zIndex(isExpanded ? 50 : -10)
    .hoverEffect()
    .onAppear {
      setupMouseEventMonitor()
    }
  }

  private func toggleExpanded() {
    withAnimation(
      .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    ) {
      isExpanded.toggle()
    }
  }

  private func setupMouseEventMonitor() {
    NSEvent.addLocalMonitorForEvents(matching: [
      .leftMouseUp, .rightMouseUp,
    ]) { event in
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
        TimelineViewSelector(selectedViewType: $selectedViewType).frame(
          maxHeight: 40
        ).fixedSize(horizontal: true, vertical: true)
        Spacer()
      }
    }
  }
}
