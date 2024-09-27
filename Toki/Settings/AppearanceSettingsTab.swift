//
//  AppearanceSettingsTab.swift
//  Toki
//
//  Created by tnixc on 27/9/2024.
//

// toki/Toki/Settings/AppearanceSettingsTab.swift

import SwiftUI

struct AppearanceSettingsTab: View {
  @AppStorage("selectedAppearance") private var selectedAppearance: Appearance =
    .system
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: Style.Layout.padding) {
      Text("Appearance").font(.title).padding()

      SettingItemGroup {
        VStack(alignment: .leading, spacing: Style.Layout.paddingSM) {
          SettingItemRow(
            title: "App Theme",
            description: "Choose the appearance of the app",
            icon: "paintbrush"
          ) {
            Picker("", selection: $selectedAppearance) {
              ForEach(Appearance.allCases, id: \.self) { appearance in
                Text(appearance.description).tag(appearance)
              }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
          }
        }
      }
      Spacer()
    }
    .onChange(of: selectedAppearance) {
      updateAppAppearance()
    }
  }

  public func updateAppAppearance() {
    switch selectedAppearance {
    case .light:
      NSApp.appearance = NSAppearance(named: .aqua)
    case .dark:
      NSApp.appearance = NSAppearance(named: .darkAqua)
    case .system:
      NSApp.appearance = nil
    }
  }
}

enum Appearance: String, CaseIterable {
  case light
  case dark
  case system

  var description: String {
    switch self {
    case .light: return "Light"
    case .dark: return "Dark"
    case .system: return "System"
    }
  }
}
