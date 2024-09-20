import SwiftUI

struct TimelineViewDay: View {
  @StateObject private var logic = TimelineViewDayLogic()

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      headerView

      GeometryReader { geometry in
        let timelineWidth = geometry.size.width
        VStack(alignment: .leading, spacing: 0) {
          hourLabelsView(width: timelineWidth - 20)
            .padding(.horizontal, 10)
          ZStack(alignment: .topLeading) {
            timelineView(width: timelineWidth)
            hoverInformationView(width: timelineWidth)
              .contentTransition(.interpolate)
              .animation(.spring(), value: logic.selectedDate)
          }
        }
      }
      .frame(height: 125)  // NOTE: Height
      timelineConfigView().contentTransition(.interpolate).animation(
        .snappy, value: logic.selectedDate)
      mostUsedAppsView()

      Spacer()

    }
    .padding()
    .frame(maxWidth: 600)
    .onAppear {
      logic.loadData(for: logic.selectedDate)
    }
    .onChange(of: logic.selectedDate) {
      logic.loadData(for: logic.selectedDate)
    }
  }

  private var headerView: some View {
    HStack {
      let day_name = formatDate(components: logic.selectedDate)
      Text("\(day_name)'s Timeline")
        .font(.title)
        .animation(.snappy, value: logic.dateString)
        .contentTransition(.numericText())
    }
  }

  private var headerContent: some View {
    Group {
      let day_name = formatDate(components: logic.selectedDate)
      Text("\(day_name)'s Timeline")
        .font(.title)
        .animation(.snappy, value: logic.dateString)
        .contentTransition(.numericText())

      Spacer()
      dateNavigationView
    }
  }

  private var dateNavigationView: some View {
    HStack {
      Button(action: { logic.changeDate(by: -1) }) {
        Image(systemName: "chevron.left").fontWeight(.bold)
          .contentShape(Rectangle())
          .frame(width: 40, height: 40)
      }
      .background(Color.primary.opacity(0.05))
      .frame(width: 40, height: 40)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .buttonStyle(.borderless)
      .hoverEffect()

      Button(action: { logic.showDatePicker.toggle() }) {
        Text(logic.dateString).fontWeight(.bold)
          .padding(.horizontal, 10)
          .frame(width: 120, height: 40)
          .contentShape(Rectangle())
      }
      .background(Color.primary.opacity(0.05))
      .frame(height: 40)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .buttonStyle(.borderless)
      .hoverEffect()
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
        Image(systemName: "chevron.right").fontWeight(.bold)
          .contentShape(Rectangle())
          .frame(width: 40, height: 40)
      }
      .background(Color.primary.opacity(0.05))
      .frame(width: 40, height: 40)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .buttonStyle(.borderless)
      .hoverEffect()
      .disabled(logic.isTodaySelected)
    }
  }

  private func hourLabelsView(width: CGFloat) -> some View {
    HStack(alignment: .top, spacing: 0) {
      ForEach(logic.hourLabels(for: width), id: \.self) { hour in
        Text("\(hour)")
          .font(.subheadline)
          .frame(width: logic.hourLabelWidth(for: width))
      }
    }
    .padding(.vertical, 4)
    .frame(width: width)
  }

  private func timelineView(width: CGFloat) -> some View {
    ZStack(alignment: .topLeading) {
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
            HStack(spacing: 6) {
              Circle()
                .fill(logic.colorForApp(usage.appName))
                .frame(width: 8, height: 8)
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
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        .frame(maxWidth: 200)
        .offset(
          x: max(0, min(logic.hoverPosition - 100, width - 200)),
          y: logic.timelineHeight + logic.hoverLineExtension
        )
      }
    }
  }

  private func backgroundView(width: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.accentColor.opacity(0.1))
      .frame(width: width, height: logic.timelineHeight)
  }

  private func activityBarsView(width: CGFloat) -> some View {
    ForEach(logic.mergeAdjacentSegments(), id: \.0) {
      startSegment, endSegment in
      let startX = logic.xPositionForSegment(startSegment, width: width)
      let endX = logic.xPositionForSegment(endSegment + 1, width: width)
      let barWidth = endX - startX

      ZStack {
        // This creates the joined appearance
        RoundedRectangle(cornerRadius: 5)
          .fill(Color.clear)
          .padding(.vertical, logic.hoverLineExtension)
          .frame(
            width: barWidth,
            height: logic.timelineHeight - logic.hoverLineExtension
          )
          .overlay(
            RoundedRectangle(cornerRadius: 5)
              .stroke(
                LinearGradient(
                  gradient: Gradient(colors: [
                    Color.gray.opacity(0.5), Color.clear.opacity(0.1),
                  ]),
                  startPoint: .top,
                  endPoint: .bottom),
                lineWidth: 1
              ).padding(.vertical, logic.hoverLineExtension / 2)
          )
        // This creates the individual colored segments
        HStack(spacing: 0) {
          ForEach(startSegment...endSegment, id: \.self) { segment in
            Rectangle()
              .fill(logic.colorForSegment(segment))
              .frame(width: barWidth / CGFloat(endSegment - startSegment + 1))
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
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
      .animation(.snappy(duration: 0.3), value: logic.isHovering)
      .animation(.snappy(duration: 0.3), value: logic.hoverPosition)
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

  private func timelineConfigView() -> some View {
    HStack {

      Toggle(isOn: $logic.showAppColors) {
        Text("App Colors")
      }
      .toggleStyle(SwitchToggleStyle(tint: .accentColor))
      .padding()
      .frame(height: 42)
      .background(Color.secondary.opacity(0.1))
      .cornerRadius(10)
      Spacer()
      dateNavigationView
    }
    .zIndex(-1)
  }

  private func mostUsedAppsView() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(!logic.mostUsedApps.isEmpty ? "Most Used Apps" : "No data")
        .font(.headline)
      ForEach(logic.mostUsedApps, id: \.appName) { appUsage in
        HStack {
          Circle()
            .fill(logic.colorForApp(appUsage.appName))
            .frame(width: 10, height: 10)
          Text(appUsage.appName)
            .font(.subheadline)
          Spacer()
          Text(logic.formatDuration(appUsage.duration))
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .transition(.blurReplace)
        .id("\(logic.selectedDate)\(appUsage.appName)")
      }
    }
    .animation(.snappy, value: logic.selectedDate)
    .padding()
    .zIndex(-1)
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(10)
  }
}
