import SwiftUI

struct PaneBackground: View {

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    Color(.clear)
      .edgesIgnoringSafeArea(.all)
    }
}

struct PaneBackground_Previews: PreviewProvider {
  static var previews: some View {
    PaneBackground()
  }
}
