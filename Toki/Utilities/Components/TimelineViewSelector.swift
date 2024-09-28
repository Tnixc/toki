import SwiftUI

struct TimelineViewSelector: View {
  @Binding var selectedViewType: TimelineViewType

  static let height: CGFloat = Style.Button.height

  var body: some View {
    UIDropdown(
      selectedOption: $selectedViewType,
      options: TimelineViewType.allCases,
      optionToString: { $0.rawValue },
      width: 120,
      height: TimelineViewSelector.height
    )
  }
}

enum TimelineViewType: String, CaseIterable {
  case day = "Day"
  case week = "Week"
  case month = "Month"
}
