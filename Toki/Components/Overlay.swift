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
  @State private var remainingTime: TimeInterval

  init(title: String, message: String, duration: TimeInterval) {
    self.title = title
    self.message = message
    self._remainingTime = State(initialValue: duration)
  }

  var body: some View {
    ZStack {
      VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)

      VStack(spacing: 20) {
        Text(title)
          .font(.largeTitle)
          .fontWeight(.bold)

        Text(message)
          .font(.title2)
        HStack(spacing: 0) {
          Text("Dismisses in ")
            .font(.title2)
            .foregroundStyle(.secondary)
          Text(String(format: "%.0f", remainingTime))
            .font(.title2)
            .foregroundStyle(.secondary)
            .contentTransition(.numericText(countsDown: true))
            .animation(.bouncy, value: remainingTime)
            .frame(width: 12)
        }
      }
      .padding()
    }
    .onAppear {
      startTimer(interval: 1)
    }
  }

  private func startTimer(interval: Double) {
    Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
      if remainingTime > 0 {
        remainingTime -= interval
      } else {
        timer.invalidate()
      }
    }
  }
}

struct VisualEffectView: NSViewRepresentable {
  let material: NSVisualEffectView.Material
  let blendingMode: NSVisualEffectView.BlendingMode

  func makeNSView(context _: Context) -> NSVisualEffectView {
    let visualEffectView = NSVisualEffectView()
    visualEffectView.material = material
    visualEffectView.blendingMode = blendingMode
    visualEffectView.state = NSVisualEffectView.State.active
    visualEffectView.isEmphasized = true
    return visualEffectView
  }

  func updateNSView(_ visualEffectView: NSVisualEffectView, context _: Context) {
    visualEffectView.material = material
    visualEffectView.blendingMode = blendingMode
  }
}
