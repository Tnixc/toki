import SwiftUI

struct TimelineViewDay: View {
  @State private var activities: [MinuteActivity] = []
  @State private var hoveredApp: String = ""
  @State private var hoverLocation: CGPoint?
  @State private var isHoveredActivityDisplayed: Bool = false
  private let day = Day()

  private let timelineHeight: CGFloat = 100

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Today's Timeline")
        .font(.title)
        .monospaced()

      GeometryReader { geometry in
        let timelineWidth = geometry.size.width

        VStack(alignment: .leading, spacing: 0) {
          // Hour labels
          HStack(alignment: .top, spacing: 0) {
            ForEach(hourLabels(for: timelineWidth), id: \.self) { hour in
              Text("\(hour)")
                .font(.caption)
                .monospaced()
                .frame(width: hourLabelWidth(for: timelineWidth))
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
              let xPosition = xPositionForDate(
                activity.minute, width: timelineWidth)
              let width = widthForDuration(1, totalWidth: timelineWidth)  // 1 minute duration

              Rectangle()
                .fill(isDisplayed(activity) ? Color.clear : Color.accentColor)
                .frame(width: width, height: timelineHeight)
                .position(x: xPosition + width / 2, y: timelineHeight / 2)
            }

            // Hour separators
            ForEach(1..<24) { hour in
              Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 1, height: timelineHeight)
                .position(
                  x: CGFloat(hour) * (timelineWidth / 24), y: timelineHeight / 2
                )
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
                  updateHoveredApp(at: location, width: timelineWidth)
                case .ended:
                  hoveredApp = ""
                  hoverLocation = nil
                  isHoveredActivityDisplayed = false
                }
              }

            // Hover indicator
            if let location = hoverLocation, !isHoveredActivityDisplayed {
              Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 2, height: timelineHeight)
                .position(x: location.x, y: timelineHeight / 2)
            }
          }
          .frame(width: timelineWidth, height: timelineHeight)
          .border(Color.gray, width: 1)

          if !isHoveredActivityDisplayed {
            Text(hoveredApp)
              .monospaced()
              .font(.caption)
              .padding(.top, 5)
          }
        }
      }
    }
    .padding()
    .onAppear(perform: loadData)
  }

  private func updateHoveredApp(at location: CGPoint, width: CGFloat) {
    hoverLocation = location
    let minute = Int((location.x / width) * 1440)
    let date = Calendar.current.date(
      byAdding: .minute, value: minute,
      to: Calendar.current.startOfDay(for: Date()))!
    if let activity = activities.first(where: {
      $0.minute <= date && date < $0.minute.addingTimeInterval(60)
    }) {
      isHoveredActivityDisplayed = isDisplayed(activity)
      hoveredApp = isHoveredActivityDisplayed ? "" : activity.appName
    } else {
      isHoveredActivityDisplayed = false
      hoveredApp = ""
    }
  }
  private func hourLabels(for width: CGFloat) -> [Int] {
    if width < 500 {
      return [0, 6, 12, 18, 24]
    } else {
      return stride(from: 0, through: 24, by: 2).map { $0 }
    }
  }

  // New function to calculate the width for each hour label
  private func hourLabelWidth(for width: CGFloat) -> CGFloat {
    let labels = hourLabels(for: width)
    return width / CGFloat(labels.count - 1)
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

  private func xPositionForDate(_ date: Date, width: CGFloat) -> CGFloat {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: date)
    let totalMinutes = CGFloat(components.hour! * 60 + components.minute!)
    return (totalMinutes / 1440.0) * width
  }

  private func widthForDuration(_ minutes: Int, totalWidth: CGFloat) -> CGFloat {
    return (CGFloat(minutes) / 1440.0) * totalWidth
  }
}
