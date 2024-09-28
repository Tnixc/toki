import SwiftUI

@main
struct TokiLauncherApp: App {
  var body: some Scene {
    WindowGroup {}
  }

  init() {
    launchMainApp()
  }

  private func launchMainApp() {
    let mainAppBundleIdentifier =
      Bundle.main.bundleIdentifier ?? "space.tnixc.Toki"
    let runningApps = NSWorkspace.shared.runningApplications
    let isRunning = runningApps.contains {
      $0.bundleIdentifier == mainAppBundleIdentifier
    }

    if !isRunning {
      let mainAppURL = NSWorkspace.shared.urlForApplication(
        withBundleIdentifier: mainAppBundleIdentifier)
      if let url = mainAppURL {
        NSWorkspace.shared.openApplication(
          at: url, configuration: NSWorkspace.OpenConfiguration(),
          completionHandler: nil)
      }
    }

    DispatchQueue.main.async {
      NSApplication.shared.terminate(nil)
    }
  }
}
