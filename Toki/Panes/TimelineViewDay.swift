import SwiftUI

struct TimelineViewDay: View {
  // MARK: - Properties
  @State private var activities: [MinuteActivity] = []
  @State private var hoveredSegment: Int? = nil
  @State private var isHovering: Bool = false
  @State private var hoverPosition: CGFloat = 0

  private let day = Day()

  // MARK: - Constants
  private let timelineHeight: CGFloat = 100
  private let segmentDuration: Int = 10  // 20-minute segments
  private let segmentCount: Int = 144  // 24 hours * 3 segments per hour
  private let hoverLineExtension: CGFloat = 10

  // MARK: - Body
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
                .font(.subheadline)
                .monospaced()
                .frame(width: hourLabelWidth(for: timelineWidth))
            }
          }
          .padding(.vertical, 4)
          .frame(width: timelineWidth)

          // Timeline
          ZStack(alignment: .topLeading) {
            if isHovering {
              let segment = Int(
                (hoverPosition / timelineWidth) * CGFloat(segmentCount))
              VStack(alignment: .leading, spacing: 4) {
                Text(timeRangeForSegment(segment))
                  .font(.subheadline)
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
              .zIndex(99)
              .padding(8)
              .background(.thickMaterial)
              .cornerRadius(8)
              .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
              .frame(maxWidth: 200)
              .offset(
                x: max(0, min(hoverPosition - 100, timelineWidth - 200)),
                y: timelineHeight + hoverLineExtension
              )
              .transition(.opacity)
            }

            // Background
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.blue.opacity(0.1))
              .frame(width: timelineWidth, height: timelineHeight)

            // Activity bars
            ForEach(mergeAdjacentSegments(), id: \.0) {
              startSegment, endSegment in
              let startX = xPositionForSegment(
                startSegment, width: timelineWidth)
              let endX = xPositionForSegment(
                endSegment + 1, width: timelineWidth)
              let width = endX - startX

              ZStack {
                RoundedRectangle(cornerRadius: 5)
                  .fill(
                    Gradient(colors: [
                      Color.accentColor.opacity(0.8),
                      Color.accentColor.opacity(0.7),
                    ])
                  )
                  .padding(.vertical, hoverLineExtension)
                  .frame(width: width, height: timelineHeight)

                // Add the thin white gradient border
                RoundedRectangle(cornerRadius: 5)
                  .stroke(
                    LinearGradient(
                      gradient: Gradient(colors: [
                        Color.gray.opacity(0.5),
                        Color.clear.opacity(0.1),
                      ]),
                      startPoint: .top,
                      endPoint: .bottom
                    ),
                    lineWidth: 1
                  )
                  .padding(.vertical, hoverLineExtension)
                  .frame(width: width, height: timelineHeight)
              }
              .position(x: startX + width / 2, y: timelineHeight / 2)

            }
            Rectangle()
              .fill(Color.white.opacity(0.7))
              .frame(width: 2, height: timelineHeight + 2 * hoverLineExtension)
              .position(x: hoverPosition, y: timelineHeight / 2)
              .opacity(isHovering ? 1 : 0)
              .animation(.spring(duration: 0.5), value: isHovering)
              .animation(.spring(duration: 0.5), value: hoverPosition)
            // Hover overlay
            Rectangle()
              .fill(Color.clear)
              .frame(width: timelineWidth, height: timelineHeight)
              .contentShape(Rectangle())
              .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                  withAnimation(.spring(duration: 0.1)) {
                    isHovering = true
                    updateHoverPosition(at: location, width: timelineWidth)
                  }
                case .ended:
                  isHovering = false
                }

              }
              .frame(width: timelineWidth, height: timelineHeight)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
              )
            // Hover information
          }

        }
      }
    }
    .padding()
    .frame(maxWidth: 600)
    .onAppear(perform: loadData)

  }

  // MARK: - Helper Methods
  private func updateHoverPosition(at location: CGPoint, width: CGFloat) {
    hoverPosition = max(0, min(location.x, width))
  }

  private func hourLabels(for width: CGFloat) -> [Int] {
    width < 500
      ? [0, 6, 12, 18, 24] : stride(from: 0, through: 24, by: 2).map { $0 }
  }

  private func hourLabelWidth(for width: CGFloat) -> CGFloat {
    let labels = hourLabels(for: width)
    return width / CGFloat(labels.count - 1)
  }

  private func loadData() {
    activities = day.getActivityForDay(date: Date())
  }

  private func xPositionForSegment(_ segment: Int, width: CGFloat) -> CGFloat {
    (CGFloat(segment) / CGFloat(segmentCount)) * width
  }

  private func timeRangeForSegment(_ segment: Int) -> String {
    let startTime = Calendar.current.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: Calendar.current.startOfDay(for: Date())
    )!
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
      to: Calendar.current.startOfDay(for: Date())
    )!
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
      .sorted { (usage1, usage2) -> Bool in
        if usage1.duration == usage2.duration {
          return usage1.appName < usage2.appName  // Sort alphabetically if durations are equal
        }
        return usage1.duration > usage2.duration  // Sort by duration (descending) otherwise
      }
  }

  private func formatDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    return "\(minutes) min"
  }
  private func isSegmentActive(_ segment: Int) -> Bool {
    let startTime = Calendar.current.date(
      byAdding: .minute, value: segment * segmentDuration,
      to: Calendar.current.startOfDay(for: Date())
    )!
    let endTime = startTime.addingTimeInterval(
      TimeInterval(segmentDuration * 60))
    let segmentActivities = activities.filter {
      $0.minute >= startTime && $0.minute < endTime
    }
    return segmentActivities.contains { !$0.isIdle }
  }

  private func mergeAdjacentSegments() -> [(Int, Int)] {
    var mergedSegments: [(Int, Int)] = []
    var currentStart: Int?

    for segment in 0..<segmentCount {
      if isSegmentActive(segment) {
        if currentStart == nil {
          currentStart = segment
        }
      } else {
        if let start = currentStart {
          mergedSegments.append((start, segment - 1))
          currentStart = nil
        }
      }
    }

    // Add the last segment if it's active
    if let start = currentStart {
      mergedSegments.append((start, segmentCount - 1))
    }

    return mergedSegments
  }

}

// MARK: - Helper Extensions
extension Array {
  func group<Key: Hashable>(by keyPath: (Element) -> Key) -> [Key: [Element]] {
    return Dictionary(grouping: self, by: keyPath)
  }
}
