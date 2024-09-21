import Foundation
import SwiftUI

struct TimelineViewDay: View {

  @StateObject private var logic = TimelineViewDayLogic()
  @Binding var selectedViewType: TimelineViewType

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      headerView
      timelineSection
      timelineConfigView()
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
        .font(.title)
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
        hourLabelsView(width: timelineWidth - 20)
          .padding(.horizontal, 10)
        ZStack(alignment: .topLeading) {
          timelineView(width: timelineWidth)
          hoverInformationView(width: timelineWidth)
            .transition(.blurReplace)
            .zIndex(99)
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
      hoverOverlayView(width: width)
    }.zIndex(99)
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
      .frame(width: width, height: logic.timelineHeight)
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
      .overlay(
        RoundedRectangle(cornerRadius: 10).stroke(
          Color.accentColor.opacity(0.3), lineWidth: 1))
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
      Image(systemName: "gearshape.fill")
        .foregroundColor(.secondary)
        .font(.system(size: 20))
    }
    .buttonStyle(PlainButtonStyle())
  }

  // MARK: - Date Navigation
  private var dateNavigationView: some View {
    HStack {
      navigationButton(
        action: { logic.changeDate(by: -1) }, iconName: "chevron.left")
      datePickerButton
      navigationButton(
        action: { logic.changeDate(by: 1) }, iconName: "chevron.right"
      )
      .disabled(logic.isTodaySelected)
    }
  }

  private func navigationButton(action: @escaping () -> Void, iconName: String)
    -> some View
  {
    Button(action: action) {
      Image(systemName: iconName).fontWeight(.bold)
        .contentShape(Rectangle())
        .frame(width: 40, height: 40)
    }
    .background(Color.primary.opacity(0.05))
    .frame(width: 40, height: 40)
    .clipShape(RoundedRectangle(cornerRadius: 10))
    .buttonStyle(.borderless)
    .hoverEffect()
  }

  private var datePickerButton: some View {
    Button(action: { logic.showDatePicker.toggle() }) {
      Text(logic.dateString).fontWeight(.bold)
        .foregroundStyle(.primary)
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
  }

  // MARK: - Most Used Apps
  private func mostUsedAppsView() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(logic.mostUsedApps.isEmpty ? "No data" : "Most Used Apps")
        .font(.headline)
        .transition(.opacity)
        .id("header-\(logic.mostUsedApps.isEmpty)")

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
          .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
      }
    }
    .animation(
      .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.3),
      value: logic.mostUsedApps
    )
    .padding()
    .background(Color.secondary.opacity(0.1))
    .cornerRadius(10)
    .transition(.scale.combined(with: .opacity))
    .zIndex(-10)
  }
}
