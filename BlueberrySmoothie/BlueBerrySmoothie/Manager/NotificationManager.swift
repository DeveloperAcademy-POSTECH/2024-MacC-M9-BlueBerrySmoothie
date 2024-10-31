//
//  NotificationManager.swift
//  Macro_Study_SwiftData
//
//  Created by 원주연 on 10/31/24.
//

import SwiftUI
import Foundation
import UserNotifications
import CoreLocation


class NotificationManager {
    static let instance = NotificationManager() //Singleton
    
    /// 제일 처음에 알림 설정을 하기 위한 함수 -> 앱이 열릴 때나 button 클릭 시 함수 호출 되도록
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success,error in
            if let error {
                print("ERROR: \(error)")
            } else {
                print("SUCCESS")
            }
        }
    }
    
    // 타이머 기반 notification
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "알람이 울립니다"
        content.body = "10초 뒤로 설정한 알람입니다."
        content.sound = .defaultCritical
        
        // 10초 후 알림
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    // 위치 기반 notification
    func requestLocationNotification() {
        let content = UNMutableNotificationContent()
        content.title = "포스텍 2정거장 전입니다."
        content.subtitle = "일어나서 내릴 준비를 해야해요!"
        content.sound = .defaultCritical
        
        let center = CLLocationCoordinate2D(latitude: 36.015764, longitude: 129.322488)
        let region = CLCircularRegion(center: center, radius: 50.0, identifier: "POIRegion")
        region.notifyOnEntry = true // 설정한 지역 구간에 들어왔을 때
        region.notifyOnExit = false // 설정한 지역 구간을 나갈 때
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error location notification: \(error.localizedDescription)")
            } else {
                print("Notification location successfully")
            }
        }
    }
}
