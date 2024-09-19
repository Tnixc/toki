import SwiftUI

struct TimelineViewDay: View {
  @State private var activities: [MinuteActivity] = []
  @State private var hoveredApp: String = ""
  @State private var hoverLocation: CGPoint?
  private let day = Day()

  private let timelineWidth: CGFloat = 960  // 40 pixels per hour
  private let timelineHeight: CGFloat = 100

  var body: some View {
    VStack {
      Text("Today's Timeline")
        .font(.title)
        .padding()

      // Hour labels
      HStack(alignment: .top, spacing: 0) {
        ForEach(0..<25) { hour in
          Text("\(hour)")
            .font(.caption)
            .frame(width: timelineWidth / 24)
        }
      }
      .frame(width: timelineWidth)

      // Timeline
      ZStack(alignment: .topLeading) {
        // Background
        Rectangle()
          .fill(Color.gray.opacity(0.1))
          .frame(width: timelineWidth, height: timelineHeight)

        // Activity bars
        ForEach(activities.indices, id: \.self) { index in
          let activity = activities[index]
          let xPosition = xPositionForDate(activity.minute)
          let width = widthForDuration(1)  // 1 minute duration

          Rectangle()
            .fill(
              isDisplayed(activity)
                ? Color.clear : colorForApp(activity.appName)
            )
            .frame(width: width, height: timelineHeight)
            .position(x: xPosition + width / 2, y: timelineHeight / 2)
        }

        // Hour separators
        ForEach(1..<24) { hour in
          Rectangle()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 1, height: timelineHeight)
            .position(
              x: CGFloat(hour) * (timelineWidth / 24), y: timelineHeight / 2)
        }

        // Hover overlay
        Rectangle()
          .fill(Color.clear)
          .frame(width: timelineWidth, height: timelineHeight)
          .contentShape(Rectangle())
          .onContinuousHover { phase in
            switch phase {
            case .active(let location):
              hoverLocation = location
              updateHoveredApp(at: location)
            case .ended:
              hoveredApp = ""
              hoverLocation = nil
            }
          }

        // hover indicator
        if let location = hoverLocation {
          Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 2, height: timelineHeight)
            .position(x: location.x, y: timelineHeight / 2)
        }
      }
      .frame(width: timelineWidth, height: timelineHeight)
      .border(Color.gray, width: 1)
      .background(
        GeometryReader { geometry in
          Color.clear
            .onHover { isHovering in
              if isHovering {
                let location = NSEvent.mouseLocation
                let viewLocation = geometry.frame(in: .global).origin
                let relativeLocation = CGPoint(
                  x: location.x - viewLocation.x,
                  y: timelineHeight - (location.y - viewLocation.y)
                )
                updateHoveredApp(at: relativeLocation)
              }
            }
        }
      )

      Text(hoveredApp).monospaced()
        .font(.caption)
        .padding(.top, 5)

    }
    .padding()
    .onAppear(perform: loadData)
  }

  private func updateHoveredApp(at location: CGPoint) {
    hoverLocation = location
    let minute = Int((location.x / timelineWidth) * 1440)
    let date = Calendar.current.date(
      byAdding: .minute, value: minute,
      to: Calendar.current.startOfDay(for: Date()))!
    hoveredApp =
      activities.first(where: {
        $0.minute <= date && date < $0.minute.addingTimeInterval(60)
      })?.appName ?? ""
  }

  private func loadData() {
    activities = day.getActivityForDay(date: Date())
  }

  private func isDisplayed(_ activity: MinuteActivity) -> Bool {
    return activity.isIdle || activity.appName.lowercased() == "loginwindow"
  }

  private func colorForApp(_ appName: String) -> Color {
    let hash = abs(appName.hashValue)
    let hue = Double(hash % 360) / 360.0
    return Color(hue: hue, saturation: 0.7, brightness: 0.9)
  }

  private func xPositionForDate(_ date: Date) -> CGFloat {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: date)
    let totalMinutes = CGFloat(components.hour! * 60 + components.minute!)
    return (totalMinutes / 1440.0) * timelineWidth
  }

  private func widthForDuration(_ minutes: Int) -> CGFloat {
    return (CGFloat(minutes) / 1440.0) * timelineWidth
  }
}

struct TimelineViewDay_Previews: PreviewProvider {
  static var previews: some View {
    TimelineViewDay()
  }
}
