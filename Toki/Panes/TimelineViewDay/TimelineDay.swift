import Foundation
import SwiftUI

struct TimelineDay: View {
  @StateObject private var logic = TimelineDayLogic()
  @Binding var selectedViewType: TimelineViewType

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      headerView
      timelineSection
      timelineConfigView()
      dayStatsView()
      mostUsedAppsView()
      Spacer()
    }
    .padding()
    .frame(maxWidth: 600)
    .onAppear { logic.loadData(for: logic.selectedDate) }
    .onChange(of: logic.selectedDate) {
      logic.loadData(for: logic.selectedDate)
    }
  }

  // MARK: - Header Section
  private var headerView: some View {
    HStack {
      let dayName = formatDate(components: logic.selectedDate)
      Text("\(dayName)'s Timeline")
        .font(.largeTitle)
        .animation(.snappy, value: logic.dateString)
        .contentTransition(.numericText())
      Spacer()
      settingsButton.offset(y: -8)
    }
  }

  // MARK: - Timeline Section
  private var timelineSection: some View {
    GeometryReader { geometry in
      let timelineWidth = geometry.size.width
      VStack(alignment: .leading, spacing: 0) {
        hourLabelsView(width: timelineWidth)
        ZStack(alignment: .topLeading) {
          if logic.isLoading {
            ProgressView()
              .frame(width: timelineWidth, height: logic.timelineHeight)
          } else {
            timelineView(width: timelineWidth)
            hoverInformationView(width: timelineWidth)
              .transition(.blurReplace)
              .zIndex(99)
          }
        }.zIndex(99)
      }.zIndex(99)
    }
    .zIndex(99)
    .frame(height: 125)
  }

  // MARK: - Hour Labels
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

  // MARK: - Timeline View
  private func timelineView(width: CGFloat) -> some View {
    ZStack(alignment: .topLeading) {
      backgroundView(width: width)
      activityBarsView(width: width)
      hoverLineView(width: width)
      endOfDayLineView(width: width)
      hoverOverlayView(width: width)
    }.zIndex(99)
  }

  private func endOfDayLineView(width: CGFloat) -> some View {
    let position = logic.endOfDayPosition(width: width)
    return Rectangle()
      .fill(Color.primary.opacity(position != 0 ? 0.1 : 0))
      .frame(
        width: 2, height: logic.timelineHeight - logic.hoverLineExtension * 2
      )
      .position(x: position, y: logic.timelineHeight / 2)
  }

  // MARK: - Hover Information
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
        .overlay(
          RoundedRectangle(cornerRadius: 10).stroke(
            Color.secondary.opacity(0.1), lineWidth: 3)
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        .frame(maxWidth: 200)
        .offset(
          x: max(0, min(logic.hoverPosition - 100, width - 200)),
          y: logic.timelineHeight + logic.hoverLineExtension)
      }
    }.zIndex(99)
  }

  // MARK: - Background View
  private func backgroundView(width: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(Color.accentColor.opacity(0.1))
      .frame(width: width + 20, height: logic.timelineHeight)
      .offset(x: -10)
      .overlay(
        RoundedRectangle(cornerRadius: 10).stroke(
          Color.accentColor.opacity(0.3), lineWidth: 1
        ).offset(x: -10)
      )
  }

  // MARK: - Activity Bars
  private func activityBarsView(width: CGFloat) -> some View {
    ForEach(logic.mergeAdjacentSegments(), id: \.0) {
      startSegment, endSegment in
      let startX = logic.xPositionForSegment(startSegment, width: width)
      let endX = logic.xPositionForSegment(endSegment + 1, width: width)
      let barWidth = endX - startX

      ZStack {
        // Outer shape (joined appearance)
        RoundedRectangle(cornerRadius: 5)
          .fill(Color.clear)
          .padding(.vertical, logic.hoverLineExtension)
          .frame(
            width: barWidth,
            height: logic.timelineHeight - logic.hoverLineExtension
          )
          .overlay(
            RoundedRectangle(cornerRadius: 5).stroke(
              Color.secondary.opacity(0.1), lineWidth: 3
            )
            .padding(.vertical, logic.hoverLineExtension / 2))

        // Inner colored segments
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

  // MARK: - Hover Line
  private func hoverLineView(width: CGFloat) -> some View {
    Rectangle()
      .fill(Color.white.opacity(0.7))
      .frame(
        width: 2, height: logic.timelineHeight + 2 * logic.hoverLineExtension
      )
      .position(x: logic.hoverPosition, y: logic.timelineHeight / 2)
      .opacity(logic.isHovering ? 1 : 0)
      .animation(
        .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.3),
        value: logic.isHovering
      )
      .animation(
        .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.3),
        value: logic.hoverPosition
      )
  }

  // MARK: - Hover Overlay
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
  }

  // MARK: - Timeline Configuration
  private func timelineConfigView() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        dateNavigationView
        Spacer()
        TimelineViewSelector(selectedViewType: $selectedViewType)
      }
      .frame(minHeight: 42)
    }.zIndex(10)
  }

  @Environment(\.openSettingsLegacy) private var openSettingsLegacy
  private var settingsButton: some View {
    Button(action: { try? openSettingsLegacy() }) {
      Image(systemName: "slider.horizontal.3")
        .foregroundColor(.secondary)
        .font(.system(size: 20))
    }
    .buttonStyle(PlainButtonStyle())
  }

  // MARK: - Date Navigation
  private var dateNavigationView: some View {
    HStack {
      navigationButton(
        action: { logic.changeDate(by: -1) }, iconName: "chevron.left"
      ).keyboardShortcut(.leftArrow, modifiers: []).keyboardShortcut(
        .init("h"), modifiers: [])
      datePickerButton
      navigationButton(
        action: { logic.changeDate(by: 1) }, iconName: "chevron.right"
      ).keyboardShortcut(.rightArrow, modifiers: []).keyboardShortcut(
        .init("l"), modifiers: []
      )
      .disabled(logic.isTodaySelected)
    }
  }

  private func navigationButton(action: @escaping () -> Void, iconName: String)
    -> some View
  {
    CustomButton(
      action: action, label: "", icon: iconName, width: 40, height: 40)
  }

  private var datePickerButton: some View {
    CustomButton(
      action: { logic.showDatePicker.toggle() }, label: logic.dateString,
      icon: "calendar",
      width: 150, height: 40
    )
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
  }

  // MARK: - day stats
  private func dayStatsView() -> some View {
    HStack {
      InfoBox {
        HStack {
          VStack {
            Image(systemName: "clock").font(.largeTitle)
          }.frame(width: 40)
          VStack(alignment: .leading) {
            Text("Active Time:")
              .font(.subheadline)
              .foregroundColor(.secondary)
            if logic.isLoading {
              VStack(alignment: .leading) {
                Text("0h 0m").foregroundColor(.clear)
              }.frame(width: 80).offset(x: -4)
            } else {
              VStack(alignment: .leading) {
                Text(logic.formatDuration(logic.activeTime))
              }
              .frame(width: 80).offset(x: -4)
            }
          }
          .font(.title)
          .foregroundColor(.primary)
        }
      }
      .animation(.spring, value: logic.activeTime)
      .transition(.blurReplace)

      InfoBox {
        VStack(alignment: .leading, spacing: 7) {
          HStack {
            Image(systemName: "rectangle.righthalf.inset.filled.arrow.right")
              .frame(width: 14)
            Text("Clocked in:")
            Spacer()
            if logic.isLoading {
              Text("0h 0m").foregroundColor(.clear)
            } else {
              Text(
                logic.clockInTime?.formatted(date: .omitted, time: .shortened)
                  ?? "N/A")
            }
          }
          HStack {
            Image(systemName: "moon.zzz.fill").frame(width: 14)
            Text("Clocked out:")
            Spacer()
            if logic.isLoading {
              Text("0h 0m").foregroundColor(.clear)
            } else {
              Text(
                logic.clockOutTime?.formatted(date: .omitted, time: .shortened)
                  ?? "N/A")
            }
          }
        }
      }
      .animation(.spring, value: logic.clockOutTime)
      .transition(.blurReplace)
    }
  }

  // MARK: - Most Used Apps
  private func mostUsedAppsView() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      if logic.isLoading {
        Text("Most Used Apps")
          .font(.headline)
        HStack {
          Spacer()
        }
        .transition(.blurReplace)

      } else {
        Text(logic.mostUsedApps.isEmpty ? "No data" : "Most Used Apps")
          .font(.headline)

        if !logic.mostUsedApps.isEmpty {
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

          }
        }
      }
    }
    .padding()
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(10)
    .overlay(
      RoundedRectangle(cornerRadius: 10).stroke(
        .secondary.opacity(0.2), lineWidth: 1)
    )
    .animation(
      .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.3),
      value: logic.mostUsedApps
    )
    .zIndex(-10)
  }
}
