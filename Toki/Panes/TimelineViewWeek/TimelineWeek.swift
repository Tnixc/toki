import SwiftUI

struct TimelineWeek: View {
  @StateObject private var logic = TimelineWeekLogic()
  @Binding var selectedViewType: TimelineViewType

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        headerView
        timelineConfigView()
        weekStatsView()
        if logic.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
          weeklyTimelines
        }
      }
      .padding()
      .frame(maxWidth: 600)
    }
    .onAppear { logic.loadData() }
  }

  // MARK: - Header Section
  private var headerView: some View {
    HStack {
      Text("Weekly Timeline")
        .font(.title)
      Spacer()
      settingsButton.offset(y: -8)
    }
  }

  // MARK: - Timeline Configuration
  private func timelineConfigView() -> some View {
    HStack {
      dateNavigationView
      Spacer()
      TimelineViewSelector(selectedViewType: $selectedViewType)
    }
    .frame(minHeight: 42)
  }

  // MARK: - Date Navigation
  private var dateNavigationView: some View {
    HStack {
      navigationButton(action: { logic.changeWeek(by: -1) }, iconName: "chevron.left")
        .keyboardShortcut(.leftArrow, modifiers: [])
      datePickerButton
      navigationButton(action: { logic.changeWeek(by: 1) }, iconName: "chevron.right")
        .keyboardShortcut(.rightArrow, modifiers: [])
        .disabled(logic.isCurrentWeek)
    }
  }

  private func navigationButton(action: @escaping () -> Void, iconName: String) -> some View {
    Button(action: action) {
      Image(systemName: iconName)
        .fontWeight(.bold)
        .contentShape(Rectangle())
        .frame(width: 40, height: 40)
    }
    .background(Color.primary.opacity(0.05))
    .frame(width: 40, height: 40)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .buttonStyle(.borderless)
  }

  private var datePickerButton: some View {
    Button(action: { logic.showDatePicker.toggle() }) {
      Text(logic.weekString)
        .fontWeight(.bold)
        .foregroundStyle(.primary)
        .padding(.horizontal, 10)
        .frame(width: 200, height: 40)
        .contentShape(Rectangle())
    }
    .background(Color.primary.opacity(0.05))
    .frame(height: 40)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .buttonStyle(.borderless)
    .popover(isPresented: $logic.showDatePicker) {
      CustomDatePicker(selectedDate: $logic.selectedDate)
        .padding()
    }
  }

  // MARK: - Week Stats
  private func weekStatsView() -> some View {
    HStack {
      statsItem(title: "Total Active Time", value: logic.formattedTotalActiveTime, icon: "clock")
      statsItem(title: "Most Active Day", value: logic.mostActiveDay, icon: "star.fill")
    }
  }

  private func statsItem(title: String, value: String, icon: String) -> some View {
    HStack {
      Image(systemName: icon)
        .font(.largeTitle)
        .frame(width: 40)
      VStack(alignment: .leading) {
        Text(title)
          .font(.subheadline)
          .foregroundColor(.secondary)
        Text(value)
          .font(.title2)
          .foregroundColor(.primary)
      }
    }
    .padding()
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(10)
  }

  // MARK: - Weekly Timelines
  private var weeklyTimelines: some View {
    VStack(spacing: 20) {
      ForEach(logic.weekDays, id: \.self) { day in
        dailyTimeline(for: day)
      }
    }
  }

  private func dailyTimeline(for day: Date) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(logic.formatDate(day))
        .font(.headline)

      GeometryReader { geometry in
        let width = geometry.size.width
        ZStack(alignment: .topLeading) {
          backgroundView(width: width)
          activityBarsView(for: day, width: width)
        }
      }
      .frame(height: 50)
    }
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
    let activities = logic.activitiesForDay(day)
    return ZStack {
      ForEach(activities) { activity in
        let startX = logic.xPositionForTime(activity.startTime, width: width)
        let endX = logic.xPositionForTime(activity.endTime, width: width)
        let barWidth = max(endX - startX, 2)

        RoundedRectangle(cornerRadius: 5)
          .fill(logic.colorForApp(activity.appName))
          .frame(width: barWidth, height: 40)
          .position(x: startX + barWidth / 2, y: 25)
      }
    }
  }

  @Environment(\.openSettingsLegacy) private var openSettingsLegacy
  private var settingsButton: some View {
    Button(action: { try? openSettingsLegacy() }) {
      Image(systemName: "gearshape.fill")
        .foregroundColor(.secondary)
        .font(.system(size: 20))
    }
    .buttonStyle(PlainButtonStyle())
  }
}
