import SwiftUI

struct CustomDatePicker: View {
  @Binding var selectedDate: Date
  @State private var currentMonth: Date = Date()

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
        ForEach(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], id: \.self) { day in
          Text(day)
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
            selectedDate: $selectedDate, today: Date())
        }
      }
    }
    .frame(width: 300, height: 350)
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
    .cornerRadius(8)

    .hoverEffect()
  }
}

struct DateCell: View {
  let index: Int
  let currentMonth: Date
  @Binding var selectedDate: Date
  let today: Date

  private let calendar = Calendar.current

  var body: some View {
    if let date = getDate(for: index) {
      let fg =
        if date > today {
          Color.secondary.opacity(0.5)
        } else if calendar.isDate(date, inSameDayAs: selectedDate) {
          Color.white
        } else if calendar.isDateInToday(date) {
          Color.blue
        } else if calendar.component(.month, from: date)
          == calendar.component(.month, from: currentMonth)
        { Color.primary } else { Color.secondary }
      let bg =
        if calendar.isDate(date, inSameDayAs: selectedDate) {
          Color.blue
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
      .background(RoundedRectangle(cornerRadius: 8).fill(bg))
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
      let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
      let monthFirstWeek = calendar.dateInterval(
        of: .weekOfMonth, for: monthInterval.start)
    else {
      return nil
    }

    let dateInterval = DateInterval(
      start: monthFirstWeek.start, end: monthInterval.end)
    let date = calendar.date(
      byAdding: .day, value: index, to: dateInterval.start)

    guard let date = date else { return nil }

    if calendar.isDate(
      date, equalTo: monthInterval.start, toGranularity: .month)
      || calendar.isDate(
        date, equalTo: monthInterval.end, toGranularity: .month)
    {
      return date
    } else if date < monthInterval.start || date >= monthInterval.end {
      return nil
    }

    return date
  }
}

struct HoverEffect: ViewModifier {
  @State private var isHovered = false

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: 8)
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
