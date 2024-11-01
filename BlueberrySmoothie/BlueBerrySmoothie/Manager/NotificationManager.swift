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


class NotificationManager: NSObject, CLLocationManagerDelegate {
    static let instance = NotificationManager() //Singleton
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
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
    //    func scheduleTestNotification() {
    //        let content = UNMutableNotificationContent()
    //        content.title = "알람이 울립니다"
    //        content.body = "10초 뒤로 설정한 알람입니다."
    //        content.sound = .defaultCritical
    //
    //        // 10초 후 알림
    //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
    //
    //        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    //        UNUserNotificationCenter.current().add(request) { error in
    //            if let error = error {
    //                print("Error scheduling notification: \(error.localizedDescription)")
    //            } else {
    //                print("Notification scheduled successfully")
    //            }
    //        }
    //    }
    
    // 위치 기반 notification
    func requestLocationNotification() {
        let content = UNMutableNotificationContent()
        content.title = "포스텍 2정거장 전입니다."
        content.subtitle = "일어나서 내릴 준비를 해야해요!"
        content.sound = .default
        
        let center = CLLocationCoordinate2D(latitude: 36.014324, longitude: 129.325603)
        let region = CLCircularRegion(center: center, radius: 5.0, identifier: "POIRegion")
        region.notifyOnEntry = true // 설정한 지역 구간에 들어왔을 때
        region.notifyOnExit = true // 설정한 지역 구간을 나갈 때
        
        locationManager.startMonitoring(for: region)
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
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
    // CLLocationManagerDelegate 메서드 추가
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("visit: \(visit))")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("들어왔습니다.")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("들어와있지 않습니다.")
    }
}
