import Foundation
import SwiftUI

struct TimelineDay: View {
  @StateObject private var logic = TimelineDayLogic()
  @Binding var selectedViewType: TimelineViewType

  private let circleSize = 10.0

  var body: some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {
      headerView
      timelineSection.padding(.bottom, Style.Layout.padding)
      timelineConfigView()
      dayStatsView()
      mostUsedAppsView()
    }
    .padding()
    .frame(maxWidth: Constants.TimelineDay.maxWidth)
    .onAppear {
      logic.loadData(for: logic.selectedDate)
    }
    .onChange(of: logic.selectedDate) {
      logic.loadData(for: logic.selectedDate)
    }
  }

  private var loadingView: some View {
    VStack {
      Text("Loading data...")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding()
    .frame(maxWidth: .infinity)
  }

  // MARK: - Header Section
  private var headerView: some View {
    HStack {
      VStackLayout(alignment: .leading) {
        let dayName = formatDate(components: logic.selectedDate)
        Text("\(dayName)'s Timeline")
          .font(.largeTitle)
          .contentTransition(.numericText()).animation(
            .bouncy, value: logic.selectedDate)
        let longDayName = formatDateLong(components: logic.selectedDate)
        Text("\(longDayName)").font(.title3).foregroundStyle(.secondary)
          .padding(.leading, Style.Layout.paddingSM)
          .contentTransition(.numericText()).animation(
            .bouncy, value: logic.selectedDate)
      }
      Spacer()
      settingsButton.offset(y: -Style.Layout.paddingSM)
    }
  }

  // MARK: - timeline section
  private var timelineSection: some View {
    GeometryReader { geometry in
      let timelineWidth = geometry.size.width
      VStack(alignment: .leading, spacing: 0) {
        hourLabelsView(width: timelineWidth)
        ZStack(alignment: .topLeading) {
          if logic.isLoading {
            loadingView(
              width: timelineWidth, height: Constants.TimelineDay.timelineHeight
            )
          } else {
            timelineView(width: timelineWidth)
              .transition(.blurReplace)
          }
          hoverInformationView(width: timelineWidth)
            .zIndex(99)
        }
        .animation(.easeInOut(duration: 0.1), value: logic.isLoading)
      }
      .zIndex(99)
    }
    .padding(.horizontal, Style.Layout.padding)
    .zIndex(99)
    .frame(
      height: Constants.TimelineDay.timelineHeight + Constants.TimelineDay
        .hoverLineExtension * 2)
  }

  private func loadingView(width: CGFloat, height: CGFloat) -> some View {
    VStack(spacing: 0) {
      ZStack(alignment: .center) {
        backgroundView(width: width + Style.Layout.paddingSM)
          .offset(x: Style.Layout.paddingSM)
          .blur(radius: 20).scaleEffect(0.8)

        Text("Loading timeline...")
          .foregroundColor(.secondary)
          .offset(y: -Constants.TimelineDay.hoverLineExtension)
      }.offset(y: Constants.TimelineDay.hoverLineExtension)
        .frame(width: width, height: height)
    }
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
    .padding(.vertical, Style.Layout.paddingSM)
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
        width: Style.Layout.borderWidth,
        height: Constants.TimelineDay.timelineHeight - Constants.TimelineDay
          .hoverLineExtension * 2
      )
      .position(x: position, y: Constants.TimelineDay.timelineHeight / 2)
  }

  // MARK: - Hover Information
  private func hoverInformationView(width: CGFloat) -> some View {
    Group {
      if logic.isHovering {
        let segment = Int(
          (logic.hoverPosition / width) * CGFloat(logic.segmentCount))
        VStack(alignment: .leading, spacing: Style.Layout.paddingSM) {
          Text(logic.timeRangeForSegment(segment))
            .font(.subheadline)
            .monospaced()

          ForEach(logic.appsForSegment(segment), id: \.appName) { usage in
            HStack(spacing: Style.Layout.paddingSM) {
              Circle()
                .fill(logic.colorForApp(usage.appName))
                .frame(
                  width: circleSize,
                  height: circleSize)
              Text(usage.appName)
              Spacer()
              Text(logic.formatDuration(usage.duration))
            }
            .font(.caption)
            .monospaced()
          }
        }
        .zIndex(99)
        .padding(Style.Layout.padding)
        .background(.thickMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
            .stroke(
              Color.secondary.opacity(0.1),
              lineWidth: Style.Layout.borderWidth)
        )
        .cornerRadius(Style.Layout.cornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        .frame(maxWidth: 200)
        .offset(
          x: max(0, min(logic.hoverPosition - 100, width - 200)),
          y: Constants.TimelineDay.timelineHeight
            + Constants.TimelineDay.hoverLineExtension)
      }
    }.zIndex(99)
  }

  // MARK: - Background View
  private func backgroundView(width: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
      .fill(Style.Timeline.bg)
      .frame(
        width: width + 2 * Style.Layout.paddingSM,
        height: Constants.TimelineDay.timelineHeight
      )
      .overlay(
        RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
          .stroke(
            Style.Timeline.border,
            lineWidth: Style.Layout.borderWidth)
      )
      .offset(x: -Style.Layout.paddingSM)
  }

  // MARK: - Activity Bars
  private func activityBarsView(width: CGFloat) -> some View {
    ForEach(logic.mergeAdjacentSegments(), id: \.0) { segment in
      ActivityBarView(
        segment: segment,
        width: width,
        logic: logic
      )
    }
  }

  private struct ActivityBarView: View {
    let segment: (Int, Int)
    let width: CGFloat
    let logic: TimelineDayLogic

    var body: some View {
      let (startSegment, endSegment) = segment
      let startX = logic.xPositionForSegment(startSegment, width: width)
      let endX = logic.xPositionForSegment(endSegment + 1, width: width)
      let barWidth = endX - startX

      ZStack {
        outerShape(barWidth: barWidth)
        innerColoredSegments(
          startSegment: startSegment, endSegment: endSegment, barWidth: barWidth
        )
      }
      .position(
        x: startX + barWidth / 2,
        y: Constants.TimelineDay.timelineHeight / 2
      )
    }

    private func outerShape(barWidth: CGFloat) -> some View {
      RoundedRectangle(cornerRadius: Style.Layout.cornerRadius / 2)
        .fill(Color.clear)
        .padding(.vertical, Constants.TimelineDay.hoverLineExtension)
        .frame(
          width: barWidth,
          height: Constants.TimelineDay.timelineHeight
            - Constants.TimelineDay.hoverLineExtension
        )
        .overlay(
          RoundedRectangle(cornerRadius: Style.Layout.cornerRadius / 2)
            .stroke(
              Color.secondary.opacity(0.1),
              lineWidth: Style.Layout.borderWidth * 3
            )
            .padding(.vertical, Constants.TimelineDay.hoverLineExtension / 2)
        )
    }

    private func innerColoredSegments(
      startSegment: Int, endSegment: Int, barWidth: CGFloat
    ) -> some View {
      HStack(spacing: 0) {
        ForEach(startSegment...endSegment, id: \.self) { segment in
          Rectangle()
            .fill(
              logic.colorForSegment(
                segment, apps: logic.appsForSegment(segment))
            )
            .frame(width: barWidth / CGFloat(endSegment - startSegment + 1))
        }
      }
      .clipShape(
        RoundedRectangle(cornerRadius: Style.Layout.cornerRadius / 2)
      )
      .padding(.vertical, Constants.TimelineDay.hoverLineExtension)
      .frame(width: barWidth, height: Constants.TimelineDay.timelineHeight)
    }
  }

  // MARK: - Hover Line
  private func hoverLineView(width: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
      .fill(Color.white.opacity(0.7))
      .frame(
        width: Style.Layout.borderWidth,
        height: Constants.TimelineDay.timelineHeight + 2
          * Constants.TimelineDay.hoverLineExtension
      )
      .position(
        x: logic.hoverPosition, y: Constants.TimelineDay.timelineHeight / 2
      )
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
      .frame(width: width, height: Constants.TimelineDay.timelineHeight)
      .contentShape(Rectangle())
      .onContinuousHover { phase in
        switch phase {
        case .active(let location):
          withAnimation(.spring(duration: 0.15)) {
            logic.isHovering = true
            logic.updateHoverPosition(at: location, width: width)
          }
        case .ended:
          logic.isHovering = false
          logic.currentHoverSegment = nil
        }
      }
      .frame(width: width, height: Constants.TimelineDay.timelineHeight)
      .clipShape(
        RoundedRectangle(cornerRadius: Style.Layout.cornerRadius))
  }

  // MARK: - Timeline Configuration
  private func timelineConfigView() -> some View {
    VStack(alignment: .leading, spacing: Style.Layout.paddingSM) {
      HStack(spacing: Style.Layout.paddingSM) {
        dateNavigationView
        Spacer()
        TimelineViewSelector(selectedViewType: $selectedViewType)
      }
      .frame(minHeight: Style.Button.height)
    }.zIndex(10)
  }

  @Environment(\.openSettingsLegacy) private var openSettingsLegacy
  private var settingsButton: some View {
    Button(action: { try? openSettingsLegacy() }) {
      Image(systemName: "slider.horizontal.3")
        .foregroundColor(.secondary)
        .font(.system(size: Style.Icon.size))
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
      action: action, label: "", icon: iconName,
      width: Style.Button.height, height: Style.Button.height)
  }

  private var datePickerButton: some View {
    CustomButton(
      action: { logic.showDatePicker.toggle() }, label: logic.dateString,
      icon: "calendar",
      width: 150, height: Style.Button.height
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
          HStack(spacing: Style.Layout.padding) {
            VStack {
              Image(systemName: "clock").font(.largeTitle)
            }.aspectRatio(1, contentMode: .fill).padding(
              .leading, Style.Layout.paddingSM)
            VStack(alignment: .leading) {
              HStack {
                Text("Active Time:")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
                Spacer()
              }
              Text(logic.formatDuration(logic.activeTime))
                .contentTransition(.numericText()).animation(
                  .smooth, value: logic.activeTime
                )
                .frame(height: 28)
                .offset(y: -2)
            }
            .frame(width: 100)
            .font(.title)
            .foregroundColor(.primary)
          }
          Spacer()
          Divider()
          Spacer()
          VStack(alignment: .leading, spacing: 7) {
            HStack {
              Image(systemName: "rectangle.righthalf.inset.filled.arrow.right")
                .frame(width: Style.Icon.size)
              Text("Clocked in:")
              Spacer()
              Text(
                logic.clockInTime?.formatted(date: .omitted, time: .shortened)
                  ?? ""
              )
              .contentTransition(.numericText()).animation(
                .bouncy, value: logic.clockOutTime)
            }
            HStack {
              Image(systemName: "moon.zzz.fill").frame(
                width: Style.Icon.size)
              Text("Clocked out:")
              Spacer()
              Text(
                logic.clockOutTime?.formatted(date: .omitted, time: .shortened)
                  ?? ""
              )
              .contentTransition(.numericText()).animation(
                .bouncy, value: logic.clockOutTime)
            }
          }
        }
      }
      .transition(.blurReplace)
    }
  }

  private func mostUsedAppsView() -> some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {
      HStack {
        Text("Most Used Apps")
          .font(.headline)
        Spacer().frame(height: Style.Layout.borderWidth)
      }
      Divider()
      ZStack {
        VStack {
          if logic.mostUsedApps.isEmpty {
            HStack {
              Text("No data available")
                .foregroundColor(.secondary)
                .padding()
            }
          } else {
            ForEach(logic.mostUsedApps, id: \.appName) { appUsage in
              HStack {
                Circle()
                  .fill(logic.colorForApp(appUsage.appName))
                  .frame(
                    width: circleSize,
                    height: circleSize)
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
        .opacity(logic.isLoading ? 0 : 1)

        if logic.isLoading {
          Text("Loading")
            .foregroundColor(.secondary)
            .padding()
            .transition(.blurReplace)
        }
      }
    }
    .padding()
    .background(Style.Box.bg)
    .cornerRadius(Style.Layout.cornerRadius)
    .overlay(
      RoundedRectangle(cornerRadius: Style.Layout.cornerRadius).stroke(
        Style.Box.border,
        lineWidth: Style.Layout.borderWidth)
    )
    .animation(
      .spring(duration: 0.3, bounce: 0.2),
      value: logic.isLoading
    )
    .animation(
      .spring,
      value: logic.mostUsedApps
    )
    .transition(.blurReplace)
    .zIndex(-10)
  }
}
