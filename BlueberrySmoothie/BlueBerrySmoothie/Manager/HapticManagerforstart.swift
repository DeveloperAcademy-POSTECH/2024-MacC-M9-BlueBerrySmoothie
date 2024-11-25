//
//  HapticManagerforstart.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/24/24.
//


import UIKit

class HapticManagerforstart {
    static let shared = HapticManagerforstart()
    
    private init() {} // 싱글턴: 외부에서 직접 초기화 방지
    
    func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    func triggerHapticNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
           let generator = UINotificationFeedbackGenerator()
           generator.notificationOccurred(type)
       }
}
