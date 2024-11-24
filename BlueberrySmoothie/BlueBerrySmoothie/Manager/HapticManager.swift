
//  HapticManager.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 11/8/24.
//

import SwiftUI
import UserNotifications
import CoreHaptics
import UIKit

// HapticManager를 설정합니다.
class HapticManager {
    private var engine: CHHapticEngine?
    static let shared = HapticManager()

    init() {
//        prepareHaptics()
    }

    func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
            let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred(intensity: 1.0)
        }
    
    func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        }
        
        func triggerSelectionFeedback() {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    
    private func prepareHaptics() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine failed to start: \(error.localizedDescription)")
        }
    }

    func playPattern() {
        guard let engine = engine else { return }

        let events = [
            CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ], relativeTime: 1, duration: 3),

            CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ], relativeTime: 4.5, duration: 3),

            CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ], relativeTime: 8, duration: 3)
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}
