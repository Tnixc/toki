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
            .foregroundColor(.primary)
          Spacer()
          Image(systemName: "chevron.down")
            .foregroundColor(.primary)
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
        VStack(alignment: .leading, spacing: 0) {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                  viewType == selectedViewType ? Color.blue : Color.clear)
            }
            .buttonStyle(.plain)
          }
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 120)
        .offset(y: 45)
        .transition(.opacity)
      }
    }
    .zIndex(100)
  }
}

struct ContentView: View {
  @State private var selectedViewType: TimelineViewType = .day

  var body: some View {
    ZStack {
      Color.black.edgesIgnoringSafeArea(.all)
      VStack {
        Spacer()
        TimelineViewSelector(selectedViewType: $selectedViewType)
        Spacer()
      }
    }
  }
}
