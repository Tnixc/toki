import SwiftUI

struct HelloWorldPane: View {

  var body: some View {
    VStack(spacing: 20) {
      Text("Hello, World!")
    }
    .navigationSubtitle("Hello, World!")
  }
}

struct HelloWorldPane_Previews: PreviewProvider {
  static var previews: some View {
    HelloWorldPane()
  }
}
