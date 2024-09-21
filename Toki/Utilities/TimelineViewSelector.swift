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
        withAnimation(
          .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
        ) {
          self.isExpanded.toggle()
        }
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
              withAnimation(
                .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
              ) {
                self.isExpanded.toggle()
              }
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
        .zIndex(50)  // Ensures the dropdown is on top
        .frame(maxHeight: 40).fixedSize(horizontal: true, vertical: true)
        .shadow(color: Color.black.opacity(0.1), radius: 9)
      }
    }
    .zIndex(isExpanded ? 50 : -10)  // Higher zIndex when
    .hoverEffect()
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
