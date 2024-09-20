import SwiftUI

struct MainView: View {
  var body: some View {
    ScrollView {
      TimelineViewDay()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
