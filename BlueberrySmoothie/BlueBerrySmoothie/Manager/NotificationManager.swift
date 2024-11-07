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
import SwiftData


class NotificationManager: NSObject, CLLocationManagerDelegate, ObservableObject, UNUserNotificationCenterDelegate {
    static let instance = NotificationManager() //Singleton
    
    @Published var notificationReceived = false // 알림 수신 상태
    
//    private let locationManager = CLLocationManager()
    var locationManager = LocationManager.instance

    
    // 새로운 초기화 메서드 추가
        init(locationManager: LocationManager) {
            super.init()
            self.locationManager = locationManager
            UNUserNotificationCenter.current().delegate = self
        }
    
    override init() {
        super.init()
//        locationManager.delegate = self
//        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().delegate = self // Set the delegate for notification handling
    }
    
    /// 사용자에게 권한허용 받는 함수
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
    func scheduleTestNotification(for alert: Alert) {
        let content = UNMutableNotificationContent()
//        content.title = "알람이 울립니다"
//        content.body = "10초 뒤로 설정한 알람입니다."
        content.title = "\(alert.busStopName) \(alert.alertStopsBefore)정거장 전입니다."
        content.subtitle = "일어나서 내릴 준비를 해야해요!"
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
    
    func requestLocationNotification(for alert: Alert) {
            let content = UNMutableNotificationContent()
            content.title = "\(alert.busStopName) \(alert.alertStopsBefore)정거장 전입니다."
            content.subtitle = "일어나서 내릴 준비를 해야해요!"
            content.sound = .default
            
            let center = CLLocationCoordinate2D(latitude: alert.busStopGpsX, longitude: alert.busStopGpsY)
            let region = CLCircularRegion(center: center, radius: 4.0, identifier: "POIRegion")
            region.notifyOnEntry = true // 설정한 지역 구간에 들어왔을 때
            region.notifyOnExit = false // 설정한 지역 구간을 나갈 때
        
//        locationManager.startMonitoring(for: region)
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error location notification: \(error.localizedDescription)")
            } else {
                print("Location notification scheduled successfully")
            }
        }
        
    }
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Foreground 상태에서 알림 수신") // Foreground 상태에서 알림 수신 확인
//        HapticHelper.shared.impact(style: .medium)
        notificationReceived = true // 알림 수신 상태 업데이트
        locationManager.stopLocationUpdates()
        completionHandler([.list, .sound, .banner])
    }
    
    // 사용자가 Notification을 탭하면 호출되는 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("알림 수신")
        notificationReceived = true // 알림 수신 상태 업데이트
        locationManager.stopLocationUpdates()
        completionHandler()
    }
    
}