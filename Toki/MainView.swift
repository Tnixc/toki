import SwiftUI

struct MainView: View {
  @State private var selectedViewType: TimelineViewType = .day

  var body: some View {
    ScrollView {
      switch selectedViewType {
      case .day:
        TimelineDay(selectedViewType: $selectedViewType)
      case .week:
        //        TimelineWeek(selectedViewType: $selectedViewType)
        Text("week")
      case .month:
        //                TimelineViewMonth(selectedViewType: $selectedViewType)
        Text("month")
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
