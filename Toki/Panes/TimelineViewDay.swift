import SwiftUI

struct TimelineViewDay: View {
  @State private var activities: [MinuteActivity] = []
  @State private var hoveredSegment: Int? = nil
  @State private var isHovering: Bool = false
  @State private var hoverPosition: CGFloat = 0

  private let day = Day()

  private let timelineHeight: CGFloat = 100
  private let segmentDuration: Int = 10  // 20-minute segments
  private let segmentCount: Int = 144  // 24 hours * 3 segments per hour
  private let hoverLineExtension: CGFloat = 20

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
            RoundedRectangle(cornerRadius: 10)
              .fill(
                LinearGradient(
                  gradient: Gradient(colors: [
                    Color.blue.opacity(0.1), Color.blue.opacity(0.3),
                  ]), startPoint: .top, endPoint: .bottom)
              )
              .frame(width: timelineWidth, height: timelineHeight)

            // Activity bars
            ForEach(mergeAdjacentSegments(), id: \.0) {
              startSegment, endSegment, opacity in
              let startX = xPositionForSegment(
                startSegment, width: timelineWidth)
              let endX = xPositionForSegment(
                endSegment + 1, width: timelineWidth)
              let width = endX - startX

              RoundedRectangle(cornerRadius: 5)
                .fill(Color.blue.opacity(opacity))
                .frame(width: width, height: timelineHeight)
                .position(x: startX + width / 2, y: timelineHeight / 2)
            }

            // Hour separators
            ForEach(1..<24) { hour in
              Rectangle()
                .fill(Color.white.opacity(0.5))
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
                  isHovering = true
                  updateHoverPosition(at: location, width: timelineWidth)
                case .ended:
                  isHovering = false
                }
              }

          }
          .frame(width: timelineWidth, height: timelineHeight)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.blue.opacity(0.3), lineWidth: 1)
          )

          if isHovering {
            Rectangle()
              .fill(Color.white.opacity(0.7))
              .frame(width: 2, height: timelineHeight + 2 * hoverLineExtension)
              .position(x: hoverPosition, y: timelineHeight / 2)
              .animation(.interactiveSpring(), value: hoverPosition)
          }

          if isHovering {
            let segment = Int(
              (hoverPosition / timelineWidth) * CGFloat(segmentCount))
            VStack(alignment: .leading) {
              Text(timeRangeForSegment(segment))
                .font(.caption)
                .monospaced()
              ForEach(appsForSegment(segment), id: \.appName) { usage in
                HStack {
                  Text(usage.appName)
                  Spacer()
                  Text(formatDuration(usage.duration))
                }
                .font(.caption)
                .monospaced()
              }
            }
            .padding(.top, 5)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: segment)
          }
        }
      }
    }
    .padding()
    .frame(maxWidth: 600)
    .onAppear(perform: loadData)
  }

  private func updateHoverPosition(at location: CGPoint, width: CGFloat) {
    hoverPosition = max(0, min(location.x, width))
  }

  private func hourLabels(for width: CGFloat) -> [Int] {
    if width < 500 {
      return [0, 6, 12, 18, 24]
    } else {
      return stride(from: 0, through: 24, by: 2).map { $0 }
    }
  }

  private func hourLabelWidth(for width: CGFloat) -> CGFloat {
    let labels = hourLabels(for: width)
    return width / CGFloat(labels.count - 1)
  }

  private func loadData() {
    activities = day.getActivityForDay(date: Date())
  }

  private func colorForSegment(_ segment: Int) -> Color {
    let startTime = Calendar.current.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: Calendar.current.startOfDay(for: Date()))!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    let segmentActivities = activities.filter {
      $0.minute >= startTime && $0.minute < endTime
    }

    if segmentActivities.allSatisfy({ $0.isIdle }) {
      return Color.gray.opacity(0.3)
    } else {
      let mostUsedApp =
        segmentActivities
        .filter { !$0.isIdle }
        .group(by: { $0.appName })
        .max(by: { $0.value.count < $1.value.count })?
        .key ?? "Unknown"
      return colorForApp(mostUsedApp)
    }
  }

  private func colorForApp(_ appName: String) -> Color {
    let hash = abs(appName.hashValue)
    let hue = Double(hash % 360) / 360.0
    return Color(hue: hue, saturation: 0.7, brightness: 0.9)
  }

  private func opacityForSegment(_ segment: Int) -> Double {
    let startTime = Calendar.current.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: Calendar.current.startOfDay(for: Date()))!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    let segmentActivities = activities.filter {
      $0.minute >= startTime && $0.minute < endTime
    }

    let activeCount = segmentActivities.filter { !$0.isIdle }.count
    let totalCount = segmentActivities.count

    return totalCount > 0 ? Double(activeCount) / Double(totalCount) : 0
  }

  private func xPositionForSegment(_ segment: Int, width: CGFloat) -> CGFloat {
    return (CGFloat(segment) / CGFloat(segmentCount)) * width
  }

  private func widthForSegment(width: CGFloat) -> CGFloat {
    return width / CGFloat(segmentCount)
  }

  private func timeRangeForSegment(_ segment: Int) -> String {
    let startTime = Calendar.current.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: Calendar.current.startOfDay(for: Date()))!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return
      "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
  }

  private func appsForSegment(_ segment: Int) -> [AppUsage] {
    let startTime = Calendar.current.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: Calendar.current.startOfDay(for: Date()))!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    let segmentActivities = activities.filter {
      $0.minute >= startTime && $0.minute < endTime
    }

    let appUsage =
      segmentActivities
      .filter { !$0.isIdle }
      .group(by: { $0.appName })
      .mapValues { activities in
        TimeInterval(activities.count) * 60  // Each activity represents 1 minute
      }

    return appUsage.map { AppUsage(appName: $0.key, duration: $0.value) }
      .sorted { $0.duration > $1.duration }
  }

  private func formatDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    return "\(minutes) min"
  }
  private func mergeAdjacentSegments() -> [(Int, Int, Double)] {
    var mergedSegments: [(Int, Int, Double)] = []
    var currentStart = 0
    var currentOpacity = opacityForSegment(0)

    for segment in 1..<segmentCount {
      let opacity = opacityForSegment(segment)
      if opacity != currentOpacity {
        mergedSegments.append((currentStart, segment - 1, currentOpacity))
        currentStart = segment
        currentOpacity = opacity
      }
    }

    // Add the last segment
    mergedSegments.append((currentStart, segmentCount - 1, currentOpacity))

    return mergedSegments
  }

}

extension Array {
  func group<Key: Hashable>(by keyPath: (Element) -> Key) -> [Key: [Element]] {
    return Dictionary(grouping: self, by: keyPath)
  }
}
