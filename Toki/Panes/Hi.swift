import SwiftUI

struct Hi: View {
  @State private var activities: [MinuteActivity] = []
  @State private var mostUsedApps: [AppUsage] = []

  private let day = Day()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("Today's Activity")
          .font(.title)

        ForEach(activities, id: \.minute) { activity in
          HStack {
            Text(formatDate(activity.minute))
            Text(activity.appName)
            Spacer()
            Text(activity.isIdle ? "Idle" : "Active")
          }
        }

        Divider()

        Text("Most Used Apps")
          .font(.title)

        ForEach(mostUsedApps, id: \.appName) { usage in
          HStack {
            Text(usage.appName)
            Spacer()
            Text(formatDuration(usage.duration))
          }
        }
      }
      .padding()
    }
    .navigationSubtitle("Activity Summary")
    .onAppear(perform: loadData)
  }

  private func loadData() {
    let today = Date()
    activities = day.getActivityForDay(date: today)
    mostUsedApps = day.getMostUsedApps(for: today)
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }

  private func formatDuration(_ duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: duration) ?? ""
  }
}

struct Hi_Previews: PreviewProvider {
  static var previews: some View {
    HelloWorldPane()
  }
}
