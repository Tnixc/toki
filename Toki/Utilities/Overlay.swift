import SwiftUI

func generateOverlay(
  title: String,
  message: String,
  seconds: Double
) -> NSWindow {
  let screen = NSScreen.main!
  let window = NSWindow(
    contentRect: screen.frame,
    styleMask: [.borderless, .fullSizeContentView],
    backing: .buffered,
    defer: false
  )

  window.level = .floating
  window.isOpaque = false
  window.hasShadow = false
  window.ignoresMouseEvents = false
  window.backgroundColor = .clear

  window.isReleasedWhenClosed = false

  let contentView = NSHostingView(
    rootView: OverlayView(title: title, message: message, duration: seconds)
  )

  contentView.frame = window.contentView!.bounds
  contentView.autoresizingMask = [.width, .height]
  window.contentView?.addSubview(contentView)

  return window
}

struct OverlayView: View {
  let title: String
  let message: String
  let duration: TimeInterval

  @State private var progress: CGFloat = 0

  var body: some View {
    ZStack {
      VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)

      VStack(spacing: 20) {
        Text(title)
          .font(.largeTitle)
          .fontWeight(.bold)

        Text(message)
          .font(.title2)

        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            Rectangle()
              .fill(Color.secondary.opacity(0.3))
              .shadow(radius: 10)

            Rectangle()
              .fill(Color.blue)
              .frame(width: geometry.size.width * progress)
          }
          .frame(height: 10)
          .cornerRadius(5)
        }
        .frame(height: 10)
        .padding(.horizontal)
      }
      .padding()
      .frame(width: 400)
      .cornerRadius(20)
    }
    .onAppear {
      withAnimation(.linear(duration: duration)) {
        progress = 1.0
      }
    }
  }
}

struct VisualEffectView: NSViewRepresentable {
  let material: NSVisualEffectView.Material
  let blendingMode: NSVisualEffectView.BlendingMode

  func makeNSView(context: Context) -> NSVisualEffectView {
    let visualEffectView = NSVisualEffectView()
    visualEffectView.material = material
    visualEffectView.blendingMode = blendingMode
    visualEffectView.state = .active
    return visualEffectView
  }

  func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    nsView.material = material
    nsView.blendingMode = blendingMode
  }
}
