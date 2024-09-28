import SwiftUI

struct FloatingView: View {
  let isVisible: Bool

  var body: some View {
    VStack {
      if isVisible {
        VStack(spacing: 10) {
          KeyRow(label: "Day View", keys: ["1"])
          KeyRow(label: "Week View", keys: ["2"])
          KeyRow(label: "Month View", keys: ["3"])
          KeyRow(label: "Previous", keys: ["􀰑"])
          KeyRow(label: "Next", keys: ["􀰌"])
          KeyRow(label: "Settings", keys: ["􀆔", ","])
        }
        .padding(.vertical, 30)
        .background(.ultraThickMaterial)
        .foregroundColor(.primary)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 20)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
      }
    }
    .padding()
    .frame(maxWidth: 300)
    .transition(.blurReplace)
  }
}

struct KeyRow: View {
  let label: String
  let keys: [String]

  var body: some View {
    HStack {
      Text(label)
      Spacer()
      ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
        if index > 0 {
          Text("+")
            .foregroundStyle(.secondary)
        }
        Text(key)
          .frame(width: 20, height: 20)
          .foregroundStyle(.secondary)
          .background(.secondary.opacity(0.1))
          .clipShape(RoundedRectangle(cornerRadius: 2))
          .overlay(
            RoundedRectangle(cornerRadius: 2)
              .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
          )
      }
    }
    .padding(.horizontal, 30)
  }
}
