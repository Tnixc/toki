import Foundation
import SwiftUI

//
//  Utils.swift
//  Toki
//
//  Created by tnixc on 19/9/2024.
//
func triggerHapticFeedback() {
  NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
}
