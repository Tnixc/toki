import AppKit
import Foundation

extension NSWindow {

  public var alwaysOnTop: Bool {
    get {
      return level.rawValue >= Int(CGWindowLevelForKey(CGWindowLevelKey.statusWindow))
    }
    set {
      if newValue {
        makeKeyAndOrderFront(nil)
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.statusWindow)))
      } else {
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.normalWindow)))
      }
    }
  }
}
