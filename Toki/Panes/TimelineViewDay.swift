import SwiftUI

struct TimelineViewDay: View {
  @StateObject private var logic = TimelineViewDayLogic()

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      headerView

      GeometryReader { geometry in
        let timelineWidth = geometry.size.width

        VStack(alignment: .leading, spacing: 0) {
          hourLabelsView(width: timelineWidth)
          timelineView(width: timelineWidth)
        }
      }
    }
    .padding()
    .frame(maxWidth: 600)
    .onAppear {
      logic.loadData(for: logic.selectedDate)
    }
    .onChange(of: logic.selectedDate) { newDate in
      logic.loadData(for: newDate)
    }
  }

  private var headerView: some View {
    HStack {
      Text("Timeline").font(.title).monospaced()
      Spacer()
      dateNavigationView
    }
  }

  private var dateNavigationView: some View {
    HStack {
      Button(action: { logic.changeDate(by: -1) }) {
        Image(systemName: "chevron.left")
      }

      Button(action: { logic.showDatePicker.toggle() }) {
        Text(logic.dateString).monospaced()
      }
      .popover(isPresented: $logic.showDatePicker) {
        CustomDatePicker(
          selectedDate: Binding(
            get: { logic.calendar.date(from: logic.selectedDate) ?? Date() },
            set: { newDate in
              logic.selectedDate = logic.calendar.dateComponents(
                [.year, .month, .day], from: newDate)
            }
          )
        )
        .padding()
      }
      Button(action: { logic.changeDate(by: 1) }) {
        Image(systemName: "chevron.right")
      }
    }
  }

  private func hourLabelsView(width: CGFloat) -> some View {
    HStack(alignment: .top, spacing: 0) {
      ForEach(logic.hourLabels(for: width), id: \.self) { hour in
        Text("\(hour)")
          .font(.subheadline)
          .monospaced()
          .frame(width: logic.hourLabelWidth(for: width))
      }
    }
    .padding(.vertical, 4)
    .frame(width: width)
  }

  private func timelineView(width: CGFloat) -> some View {
    ZStack(alignment: .topLeading) {
      hoverInformationView(width: width)
      backgroundView(width: width)
      activityBarsView(width: width)
      hoverLineView(width: width)
      hoverOverlayView(width: width)
    }
  }

  private func hoverInformationView(width: CGFloat) -> some View {
    Group {
      if logic.isHovering {
        let segment = Int(
          (logic.hoverPosition / width) * CGFloat(logic.segmentCount))
        VStack(alignment: .leading, spacing: 4) {
          Text(logic.timeRangeForSegment(segment))
            .font(.subheadline)
            .monospaced()
          ForEach(logic.appsForSegment(segment), id: \.appName) { usage in
            HStack {
              Text(usage.appName)
              Spacer()
              Text(logic.formatDuration(usage.duration))
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
          x: max(0, min(logic.hoverPosition - 100, width - 200)),
          y: logic.timelineHeight + logic.hoverLineExtension
        )
        .transition(.opacity)
      }
    }
  }

  private func backgroundView(width: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.blue.opacity(0.1))
      .frame(width: width, height: logic.timelineHeight)
  }

  private func activityBarsView(width: CGFloat) -> some View {
    ForEach(logic.mergeAdjacentSegments(), id: \.0) {
      startSegment, endSegment in
      let startX = logic.xPositionForSegment(startSegment, width: width)
      let endX = logic.xPositionForSegment(endSegment + 1, width: width)
      let barWidth = endX - startX

      ZStack {
        RoundedRectangle(cornerRadius: 5)
          .fill(
            Gradient(colors: [
              Color.accentColor.opacity(0.8), Color.accentColor.opacity(0.7),
            ])
          )
          .padding(.vertical, logic.hoverLineExtension)
          .frame(width: barWidth, height: logic.timelineHeight)

        RoundedRectangle(cornerRadius: 5)
          .stroke(
            LinearGradient(
              gradient: Gradient(colors: [
                Color.gray.opacity(0.5), Color.clear.opacity(0.1),
              ]),
              startPoint: .top,
              endPoint: .bottom),
            lineWidth: 1
          )
          .padding(.vertical, logic.hoverLineExtension)
          .frame(width: barWidth, height: logic.timelineHeight)
      }
      .position(x: startX + barWidth / 2, y: logic.timelineHeight / 2)
    }
  }

  private func hoverLineView(width: CGFloat) -> some View {
    Rectangle()
      .fill(Color.white.opacity(0.7))
      .frame(
        width: 2, height: logic.timelineHeight + 2 * logic.hoverLineExtension
      )
      .position(x: logic.hoverPosition, y: logic.timelineHeight / 2)
      .opacity(logic.isHovering ? 1 : 0)
      .animation(.spring(duration: 0.5), value: logic.isHovering)
      .animation(.spring(duration: 0.5), value: logic.hoverPosition)
  }

  private func hoverOverlayView(width: CGFloat) -> some View {
    Rectangle()
      .fill(Color.clear)
      .frame(width: width, height: logic.timelineHeight)
      .contentShape(Rectangle())
      .onContinuousHover { phase in
        switch phase {
        case .active(let location):
          withAnimation(.spring(duration: 0.1)) {
            logic.isHovering = true
            logic.updateHoverPosition(at: location, width: width)
          }
        case .ended:
          logic.isHovering = false
          logic.currentHoverSegment = nil
        }
      }
      .frame(width: width, height: logic.timelineHeight)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10).stroke(
          Color.accentColor.opacity(0.3), lineWidth: 1))
  }
}
