import SwiftUI

struct CustomDatePicker: View {
  @Binding var selectedDate: Date
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

      HStack {
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
          DateCell(
            index: index, currentMonth: currentMonth,
            selectedDate: $selectedDate, today: Date(),
            firstDayOfWeek: firstDayOfWeek)
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

struct NavigationButton: View {
  enum Direction {
    case forward, backward
  }

  let direction: Direction
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: direction == .forward ? "arrow.right" : "arrow.left")
        .fontWeight(.bold)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
    .buttonStyle(PlainButtonStyle())
    .cornerRadius(10)

    .hoverEffect()
  }
}

struct DateCell: View {
  let index: Int
  let currentMonth: Date
  @Binding var selectedDate: Date
  let today: Date
  let firstDayOfWeek: Int

  private let calendar = Calendar.current

  var body: some View {
    if let date = getDate(for: index) {
      let fg =
        if date > today {
          Color.secondary.opacity(0.5)
        } else if calendar.isDate(date, inSameDayAs: selectedDate) {
          Color.white
        } else if calendar.isDateInToday(date) {
          Color.accentColor
        } else if calendar.component(.month, from: date)
          == calendar.component(.month, from: currentMonth)
        { Color.primary } else { Color.secondary }
      let bg =
        if calendar.isDate(date, inSameDayAs: selectedDate) {
          Color.accentColor
        } else {
          Color.clear
        }
      Button(action: {
        if date <= today {
          selectedDate = date
        }
      }) {
        Text(String(calendar.component(.day, from: date)))
          .frame(width: 42, height: 42)
          .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
      .background(RoundedRectangle(cornerRadius: 10).fill(bg))
      .foregroundColor(fg)
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
}

struct HoverEffect: ViewModifier {
  @State private var isHovered = false

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(isHovered ? Color.gray.opacity(0.2) : Color.clear)
      )
      .onHover { hovering in
        isHovered = hovering
      }
  }
}
struct ConditionalHoverEffect: ViewModifier {
  let isEnabled: Bool

  func body(content: Content) -> some View {
    if isEnabled {
      content.hoverEffect()
    } else {
      content
    }
  }
}

extension View {
  func hoverEffect() -> some View {
    self.modifier(HoverEffect())
  }
}
