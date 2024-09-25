// ExportSettingsTab.swift

import SwiftUI

struct ExportSettingsTab: View {
  @State private var startDate: Date?
  @State private var endDate: Date?
  @State private var showDatePicker = false
  @State private var showingExportAlert = false
  @State private var alertMessage = ""

  var body: some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {
      Text("Export").font(.title).padding()

      SettingItem(
        title: "Export All Data",
        description: "Export all activity data to CSV format.",
        icon: "shippingbox"
      ) {
        CustomButton(
          action: exportAllData,
          label: "Export All",
          icon: "arrow.down.doc.fill",
          width: 120,
          height: Style.Button.heightSM
        )
      }

      SettingItem(
        title: "Export Date Range",
        description: "Export activity data for a specific date range.",
        icon: "calendar"
      ) {
        CustomButton(
          action: { showDatePicker.toggle() },
          label: "Select Date Range",
          icon:
            "arrowtriangle.right.and.line.vertical.and.arrowtriangle.left.fill",
          width: 180,
          height: Style.Button.heightSM
        )
        .popover(isPresented: $showDatePicker) {
          VStack {
            MultiDatePicker(startDate: $startDate, endDate: $endDate)
              .frame(
                width: Constants.DatePicker.width,
                height: Constants.DatePicker.height)
            CustomButton(
              action: {
                exportSelectedDateRange()
                showDatePicker = false
              },
              label: "Export Selected Range",
              icon: "arrow.down.doc.fill",
              height: Style.Button.heightSM
            )
            .padding()
            .disabled(startDate == nil || endDate == nil)
          }
          .padding()
        }
      }

      SettingItem(
        title: "Show Database File",
        description: "Open the database file location in Finder.",
        icon: "folder"
      ) {
        CustomButton(
          action: showDatabaseInFinder,
          label: "Show in Finder",
          icon: "folder",
          height: Style.Button.heightSM
        )
      }

      Spacer()
    }
    .alert(isPresented: $showingExportAlert) {
      Alert(
        title: Text("Export"),
        message: Text(alertMessage),
        dismissButton: .default(Text("OK"))
      )
    }
  }

  private func exportAllData() {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.commaSeparatedText]
    savePanel.nameFieldStringValue = "Toki_All.csv"

    if savePanel.runModal() == .OK {
      guard let url = savePanel.url else { return }

      do {
        try ExportManager.shared.exportAllData(to: url)
        alertMessage = "All data exported successfully!"
      } catch {
        alertMessage = "Error exporting data: \(error.localizedDescription)"
      }
      showingExportAlert = true
    }
  }

  private func exportSelectedDateRange() {
    guard let start = startDate, let end = endDate else {
      alertMessage = "Please select both start and end dates."
      showingExportAlert = true
      return
    }

    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.commaSeparatedText]
    savePanel.nameFieldStringValue = "activity_data_range.csv"

    if savePanel.runModal() == .OK, let url = savePanel.url {
      do {
        try ExportManager.shared.exportDateRange(from: start, to: end, to: url)
        alertMessage = "Selected date range data exported successfully!"
        showingExportAlert = true
      } catch {
        alertMessage = "Error exporting data: \(error.localizedDescription)"
        showingExportAlert = true
      }
    }
  }

  private func showDatabaseInFinder() {
    let path = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
    ).first!
    let dbURL = URL(fileURLWithPath: path).appendingPathComponent(
      Constants.dbFileName)
    NSWorkspace.shared.selectFile(dbURL.path, inFileViewerRootedAtPath: path)
  }
}
