import SwiftUI

struct TimelineWeek: View {
  @StateObject private var logic = TimelineWeekLogic()
  @Binding var selectedViewType: TimelineViewType

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      headerView
      weekSelector
      timelineSection
      weekStatsView()
      mostUsedAppsView()
      Spacer()
    }
    .padding()
    .frame(maxWidth: .infinity)
    .onAppear { logic.loadData() }
    .onChange(of: logic.selectedWeekStart) {
      logic.loadData()
    }
  }

  // MARK: - Header Section
  private var headerView: some View {
    HStack {
      Text("Week's Timeline")
        .font(.title)
      Spacer()
      settingsButton.offset(y: -8)
    }
  }

  // MARK: - Week Selector
  private var weekSelector: some View {
    HStack {
      Button(action: { logic.changeWeek(by: -1) }) {
        Image(systemName: "chevron.left").fontWeight(.bold)
      }
      .keyboardShortcut(.leftArrow, modifiers: [])

      Text(logic.weekRangeString)
        .font(.headline)

      Button(action: { logic.changeWeek(by: 1) }) {
        Image(systemName: "chevron.right").fontWeight(.bold)
      }
      .keyboardShortcut(.rightArrow, modifiers: [])
      .disabled(logic.isCurrentWeekSelected)

      Spacer()
      TimelineViewSelector(selectedViewType: $selectedViewType)
    }
    .frame(minHeight: 42)
  }

  // MARK: - Timeline Section
  private var timelineSection: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(alignment: .top, spacing: 10) {
        hourLabelsView()
        ForEach(0..<7) { dayIndex in
          dayColumn(for: dayIndex)
        }
      }
    }
    .frame(height: logic.timelineHeight + 30)
  }

  private func hourLabelsView() -> some View {
    VStack(alignment: .trailing, spacing: 0) {
      Text("").frame(height: 30)  // Empty space for day label
      ForEach(logic.hourLabels, id: \.self) { hour in
        Text(hour)
          .font(.caption)
          .frame(height: 20)
      }
    }
    .frame(width: 40)
  }

  private func dayColumn(for dayIndex: Int) -> some View {
    VStack(spacing: 0) {
      Text(logic.dayNames[dayIndex])
        .font(.caption)
        .frame(height: 30)

      VStack(spacing: 0) {
        ForEach(logic.activitiesForDay(dayIndex), id: \.timestamp) { activity in
          Rectangle()
            .fill(logic.colorForApp(activity.appName))
            .frame(
              height: CGFloat(Watcher().INTERVAL) / 86400 * logic.timelineHeight
            )
        }
      }
      .frame(width: 40)
      .background(Color.secondary.opacity(0.1))
      .cornerRadius(5)
    }
  }

  // MARK: - Week Stats View
  private func weekStatsView() -> some View {
    HStack {
      HStack {
        VStack {
          Image(systemName: "clock").font(.largeTitle)
        }.frame(width: 40)
        VStack(alignment: .leading) {
          Text("Total Active Time:")
            .font(.subheadline)
            .foregroundColor(.secondary)
          if logic.isLoading {
            Text("0h 0m").foregroundColor(.clear)
          } else {
            Text(logic.formatDuration(logic.totalActiveTime))
          }
        }
        .font(.title)
        .foregroundColor(.primary)
      }
      .padding()
      .background(Color.secondary.opacity(0.1))
      .cornerRadius(10)

      VStack(alignment: .leading, spacing: 7) {
        HStack {
          Image(systemName: "chart.bar.fill").frame(width: 14)
          Text("Daily Average:")
          Spacer()
          if logic.isLoading {
            Text("0h 0m").foregroundColor(.clear)
          } else {
            Text(logic.formatDuration(logic.averageDailyActiveTime))
          }
        }
        HStack {
          Image(systemName: "arrow.up.right").frame(width: 14)
          Text("Most Active Day:")
          Spacer()
          if logic.isLoading {
            Text("N/A").foregroundColor(.clear)
          } else {
            Text(logic.mostActiveDay)
          }
        }
      }
      .padding()
      .background(Color.secondary.opacity(0.1))
      .cornerRadius(10)
    }
  }

  // MARK: - Most Used Apps View
  private func mostUsedAppsView() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      if logic.isLoading {
        Text("Most Used Apps")
          .font(.headline)
        HStack {
          Spacer()
        }
      } else {
        Text(logic.mostUsedApps.isEmpty ? "No data" : "Most Used Apps")
          .font(.headline)

        if !logic.mostUsedApps.isEmpty {
          ForEach(logic.mostUsedApps.prefix(5), id: \.appName) { appUsage in
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
          }
        }
      }
    }
    .padding()
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(10)
    .animation(
      .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.3),
      value: logic.mostUsedApps)
  }

  // MARK: - Settings Button
  @Environment(\.openSettings) private var openSettings
  private var settingsButton: some View {
    Button(action: { openSettings() }) {
      Image(systemName: "gearshape.fill")
        .foregroundColor(.secondary)
        .font(.system(size: 20))
    }
    .buttonStyle(PlainButtonStyle())
  }
}
