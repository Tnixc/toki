import SwiftUI

struct TimelineWeek: View {
  @StateObject private var logic = TimelineWeekLogic()
  @Binding var selectedViewType: TimelineViewType

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      headerView
      weekConfigView()
      ScrollView {
        VStack(spacing: 20) {
          ForEach(logic.weekDays, id: \.self) { day in
            dayView(for: day)
          }
        }
      }
    }
    .padding()
    .frame(maxWidth: 600)
    .onAppear {
      logic.loadData()
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
    CustomButton(
      action: action, label: "", icon: iconName, width: 40, height: 40)
  }

  private func dayView(for day: Date) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(logic.formatDate(day))
        .font(.headline)
      timelineView(for: day)
      dayStatsView(for: day)
    }
  }

  private func timelineView(for day: Date) -> some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      ZStack(alignment: .topLeading) {
        backgroundView(width: width)
        activityBarsView(for: day, width: width)
      }
    }
    .frame(height: 50)
  }

  private func backgroundView(width: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.accentColor.opacity(0.1))
      .frame(width: width, height: 50)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
      )
  }

  private func activityBarsView(for day: Date, width: CGFloat) -> some View {
    ForEach(logic.mergeAdjacentSegments(for: day), id: \.0) {
      startSegment, endSegment in
      let startX = logic.xPositionForSegment(startSegment, width: width)
      let endX = logic.xPositionForSegment(endSegment + 1, width: width)
      let barWidth = endX - startX

      RoundedRectangle(cornerRadius: 5)
        .fill(logic.colorForSegment(startSegment, day: day))
        .frame(width: barWidth, height: 50)
        .position(x: startX + barWidth / 2, y: 25)
    }
  }

  private func dayStatsView(for day: Date) -> some View {
    HStack {
      Text("Active: \(logic.formatDuration(logic.activeTimeForDay(day)))")
      Spacer()
      Text("Start: \(logic.clockInTimeForDay(day))")
      Spacer()
      Text("End: \(logic.clockOutTimeForDay(day))")
    }
    .font(.caption)
    .foregroundColor(.secondary)
  }
}
