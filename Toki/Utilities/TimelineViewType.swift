import SwiftUI

enum TimelineViewType: String, CaseIterable {
  case day = "Day"
  case week = "Week"
  case month = "Month"
}

struct TimelineViewSelector: View {
  @Binding var selectedViewType: TimelineViewType

  var body: some View {
    Menu {
      ForEach(TimelineViewType.allCases, id: \.self) { viewType in
        Button(action: {
          selectedViewType = viewType
        }) {
          Text(viewType.rawValue)
        }
      }
    } label: {
      HStack {
        Text(selectedViewType.rawValue)
        Image(systemName: "chevron.down")
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(Color.secondary.opacity(0.1))
      .cornerRadius(8)
    }
    .menuStyle(BorderlessButtonMenuStyle())
  }
}
