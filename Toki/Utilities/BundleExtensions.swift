import Foundation

extension Bundle {

  var name: String {
    func string(for key: String) -> String? {
      object(forInfoDictionaryKey: key) as? String
    }
    return string(for: "CFBundleDisplayName")
      ?? string(for: "CFBundleName")
      ?? "N/A"
  }
}

extension Bundle {

  var version: String {
    infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
  }

  var buildVersion: String {
    infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
  }
}
