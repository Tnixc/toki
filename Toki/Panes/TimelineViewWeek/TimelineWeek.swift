import SwiftUI

struct TimelineWeek: View {
  @StateObject private var logic = TimelineWeekLogic()
  @Binding var selectedViewType: TimelineViewType
  @State private var firstDayOfWeek: Int = UserDefaults.standard.integer(
    forKey: "firstDayOfWeek")

  private let hourLabelWidth: CGFloat = 50
  private let displayedHours = Constants.TimelineWeek.displayedHours

  var body: some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {
      headerView
      weekConfigView()
      weekStatsView
      weekTimelineView
    }
    .onAppear {
      logic.loadData()
    }

    .onReceive(
      NotificationCenter.default.publisher(for: .firstDayOfWeekChanged)
    ) { _ in
      firstDayOfWeek = UserDefaults.standard.integer(forKey: "firstDayOfWeek")
      logic.updateWeekDays(firstDayOfWeek: firstDayOfWeek)
    }
  }

  private var headerView: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("Week's Timeline")
          .font(.largeTitle)
        Text("\(logic.weekStartString) - \(logic.weekEndString)")
          .font(.title3)
          .foregroundStyle(.secondary)
      }.padding(.horizontal)
      Spacer()
    }
  }

  private func weekConfigView() -> some View {
    HStack {
      dateNavigationView
      Spacer()
      TimelineViewSelector(selectedViewType: $selectedViewType)
    }
  }

  private var dateNavigationView: some View {
    HStack {
      navigationButton(
        action: { logic.changeWeek(by: -1) }, iconName: "chevron.left")
      Text(logic.weekRangeString)
        .frame(width: 200)
      navigationButton(
        action: { logic.changeWeek(by: 1) }, iconName: "chevron.right"
      )
      .disabled(logic.isCurrentWeek)
    }
  }

  private func navigationButton(action: @escaping () -> Void, iconName: String)
    -> some View
  {
    UIButton(action: action, icon: iconName, width: 40, height: 40)
  }

  private var weekStatsView: some View {
    InfoBox {
      VStack(alignment: .leading, spacing: 10) {
        HStack {
          statsItem(
            title: "Earliest Clock In",
            value: logic.earliestClockIn?.formatted(
              date: .omitted, time: .shortened) ?? "N/A")
          Spacer()
          statsItem(
            title: "Latest Clock Out",
            value: logic.latestClockOut?.formatted(
              date: .omitted, time: .shortened) ?? "N/A")
        }
        HStack {
          statsItem(
            title: "Average Clock In",
            value: logic.averageClockIn?.formatted(
              date: .omitted, time: .shortened) ?? "N/A")
          Spacer()
          statsItem(
            title: "Average Clock Out",
            value: logic.averageClockOut?.formatted(
              date: .omitted, time: .shortened) ?? "N/A")
        }
        statsItem(
          title: "Average Active Time",
          value: TimelineUtils.formatDuration(logic.averageActiveTime) ?? "N/A")
      }
    }
  }

  private func statsItem(title: String, value: String) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
      Text(value)
        .font(.subheadline)
    }
  }

  private var weekTimelineView: some View {
    GeometryReader { geometry in
      HStack(alignment: .top, spacing: 0) {
        hourLabels(height: geometry.size.height)
          .frame(width: hourLabelWidth)
          .padding(.vertical)

        HStack(spacing: 10) {
          ForEach(logic.weekDays, id: \.self) { day in
            dayColumn(for: day, height: geometry.size.height)
          }
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 10).fill(
          Style.Colors.accent.opacity(0.1))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10).stroke(
          Style.Colors.accent.opacity(0.3), lineWidth: 1)
      )
      .overlay(loadingOverlay)
    }
    .frame(height: 500)
  }

  private var loadingOverlay: some View {
    Group {
      if logic.isLoading {
        ZStack {
          Color.black.opacity(0.3)
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.5)
        }
      }
    }
  }

  private func hourLabels(height: CGFloat) -> some View {
    VStack(spacing: 0) {
      ForEach(displayedHours, id: \.self) { hour in
        Text("\(hour):00")
          .font(.caption)
          .frame(
            height: (height - 20) / CGFloat(displayedHours.count - 1),
            alignment: .top)
      }
    }
  }

  private func dayColumn(for day: Date, height: CGFloat) -> some View {
    VStack(spacing: 0) {
      Text(logic.formatWeekday(day))
        .font(.caption)
        .frame(height: 20)
      ZStack(alignment: .top) {
        VStack(spacing: 0) {
          ForEach(displayedHours, id: \.self) { _ in
            Divider().opacity(0.5)
            Spacer()
          }
        }

        ForEach(logic.mergeAdjacentSegments(for: day), id: \.0) {
          startSegment, endSegment in
          let startY = logic.yPositionForSegment(
            startSegment, height: height - 20)
          let endY = logic.yPositionForSegment(
            endSegment + 1, height: height - 20)
          let barHeight = max(0, endY - startY)

          VStack(spacing: 0) {
            ForEach(startSegment...endSegment, id: \.self) { segment in
              Rectangle()
                .fill(logic.colorForSegment(segment, day: day))
                .frame(
                  height: (barHeight / CGFloat(endSegment - startSegment + 1)))
            }
          }
          .frame(height: barHeight)
          .clipShape(RoundedRectangle(cornerRadius: 5))
          .offset(y: startY)
        }
      }
      .frame(height: height - 20)
    }
  }
}
