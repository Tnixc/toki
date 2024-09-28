import SwiftUI

struct TimelineWeek: View {
  @StateObject private var logic = TimelineWeekLogic()
  @Binding var selectedViewType: TimelineViewType
  @State private var firstDayOfWeek: Int = UserDefaults.standard.integer(
    forKey: "firstDayOfWeek")

  private let maxWidth: CGFloat = 800
  private let dayColumnWidth: CGFloat = 100
  private let hourLabelWidth: CGFloat = 50
  private let displayedHours = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      headerView
      weekConfigView()
      weekTimelineView
    }
    .padding()
    .frame(maxWidth: maxWidth)
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
      }
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
    UIButton(
      action: action, label: "", icon: iconName, width: 40, height: 40)
  }

  private var weekTimelineView: some View {
    GeometryReader { geometry in
      HStack(alignment: .top, spacing: 0) {
        hourLabels(height: geometry.size.height)
          .frame(width: hourLabelWidth)

        HStack(spacing: 0) {
          ForEach(logic.weekDays, id: \.self) { day in
            dayColumn(for: day, height: geometry.size.height)
          }
        }
        .frame(width: dayColumnWidth * 7)
      }
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(Style.Colors.accent.opacity(0.1))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Style.Colors.accent.opacity(0.3), lineWidth: 1)
      )
    }
    .frame(height: 500)
  }

  private func hourLabels(height: CGFloat) -> some View {
    VStack(spacing: 0) {
      Text("Hour").font(.caption).frame(height: 20)
      ForEach(displayedHours.dropLast(), id: \.self) { hour in
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
          ForEach(displayedHours.dropLast(), id: \.self) { _ in
            Divider()
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

          RoundedRectangle(cornerRadius: 5)
            .fill(logic.colorForSegment(startSegment, day: day))
            .frame(width: dayColumnWidth - 2, height: barHeight)
            .position(x: (dayColumnWidth - 2) / 2, y: startY + barHeight / 2)
        }
      }
      .frame(height: height - 20)
    }
    .frame(width: dayColumnWidth)
  }
}
