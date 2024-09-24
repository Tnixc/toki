import SwiftUI

struct MultiDatePicker: View {
  @Binding var startDate: Date?
  @Binding var endDate: Date?
  @State private var currentMonth: Date = Date()
  @State private var firstDayOfWeek: Int = UserDefaults.standard.integer(
    forKey: "firstDayOfWeek")

  private let calendar = Calendar.current
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
  }()

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack {
        NavigationButton(direction: .backward) {
          changeMonth(by: -1)
        }

        Spacer()

        Text(dateFormatter.string(from: currentMonth))
          .font(.headline)

        Spacer()

        NavigationButton(direction: .forward) {
          changeMonth(by: 1)
        }
        .disabled(
          calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month))
      }
      .padding(.horizontal)

      HStack(spacing: 0) {
        ForEach(0..<7) { index in
          let weekdayIndex = mod((index + firstDayOfWeek - 1), 7)
          let dayname = Calendar.current.weekdaySymbols[weekdayIndex]
          Text(dayname.capitalized.prefix(3))
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
        }
      }

      LazyVGrid(
        columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
        alignment: .leading, spacing: 0
      ) {
        ForEach(0..<42, id: \.self) { index in
          MultiDateCell(
            index: index, currentMonth: currentMonth, startDate: $startDate,
            endDate: $endDate, today: Date(), firstDayOfWeek: firstDayOfWeek)
        }
      }
    }
    .frame(width: 300, height: 350)
    .onReceive(
      NotificationCenter.default.publisher(for: .firstDayOfWeekChanged)
    ) { _ in
      firstDayOfWeek = UserDefaults.standard.integer(forKey: "firstDayOfWeek")
    }
  }

  private func changeMonth(by value: Int) {
    if let newDate = calendar.date(
      byAdding: .month, value: value, to: currentMonth)
    {
      currentMonth = min(newDate, Date())
    }
  }
}

struct MultiDateCell: View {
  let index: Int
  let currentMonth: Date
  @Binding var startDate: Date?
  @Binding var endDate: Date?
  let today: Date
  let firstDayOfWeek: Int

  private let calendar = Calendar.current

  var body: some View {
    if let date = getDate(for: index) {
      let isInRange = isDateInRange(date)
      let isStartDate = calendar.isDate(
        date, inSameDayAs: startDate ?? Date.distantPast)
      let isEndDate = calendar.isDate(
        date, inSameDayAs: endDate ?? Date.distantFuture)

      Button(action: {
        selectDate(date)
      }) {
        Text(String(calendar.component(.day, from: date)))
          .frame(width: 42, height: 42)
          .background(
            backgroundColor(
              for: date, isInRange: isInRange, isStartDate: isStartDate,
              isEndDate: isEndDate)
          )
          .foregroundColor(
            foregroundColor(
              for: date, isInRange: isInRange, isStartDate: isStartDate,
              isEndDate: isEndDate)
          )
          .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      .buttonStyle(.borderless)
      .disabled(date > today)
      .modifier(ConditionalHoverEffect(isEnabled: date <= today))
    } else {
      Color.clear
        .frame(width: 40, height: 40)
    }
  }

  private func getDate(for index: Int) -> Date? {
    guard
      let monthInterval = calendar.dateInterval(of: .month, for: currentMonth)
    else {
      return nil
    }

    let monthStart = monthInterval.start
    let weekdayOfMonthStart = calendar.component(.weekday, from: monthStart)
    let daysToAdd = (7 + weekdayOfMonthStart - firstDayOfWeek) % 7

    guard
      let startDate = calendar.date(
        byAdding: .day, value: -daysToAdd, to: monthStart)
    else {
      return nil
    }

    return calendar.date(byAdding: .day, value: index, to: startDate)
  }

  private func selectDate(_ date: Date) {
    if startDate == nil {
      // First click: set start date
      startDate = date
      endDate = nil
    } else if endDate == nil {
      // Second click: set end date
      if date < startDate! {
        // If end date is before start date, swap them
        endDate = startDate
        startDate = date
      } else {
        endDate = date
      }
    } else {
      // Subsequent clicks: reset and set new start date
      startDate = date
      endDate = nil
    }
  }

  private func isDateInRange(_ date: Date) -> Bool {
    guard let start = startDate, let end = endDate else { return false }
    return date >= start && date <= end
  }

  private func backgroundColor(
    for date: Date, isInRange: Bool, isStartDate: Bool, isEndDate: Bool
  ) -> Color {
    if isStartDate || isEndDate {
      return .accentColor
    } else {
      return .clear
    }
  }

  private func foregroundColor(
    for date: Date, isInRange: Bool, isStartDate: Bool, isEndDate: Bool
  ) -> Color {
    if date > today {
      return .secondary.opacity(0.5)
    } else if isStartDate || isEndDate {
      return .white
    } else if isInRange {
      return .accentColor
    } else if calendar.component(.month, from: date)
      == calendar.component(.month, from: currentMonth)
    {
      return .primary
    } else {
      return .secondary
    }
  }
}
