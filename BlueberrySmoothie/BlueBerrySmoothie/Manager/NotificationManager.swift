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
import AVFoundation


class NotificationManager: NSObject, CLLocationManagerDelegate, ObservableObject, UNUserNotificationCenterDelegate {
    static let instance = NotificationManager() //Singleton
    @Published var notificationReceived = false // 알림 수신 상태
    let hapticManager = HapticManager()
    
    override init() {
        super.init()
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
    
    //이어폰에 연결된 경우에만 소리알림 제공
    func isHeadphonesConnected() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let outputs = audioSession.currentRoute.outputs
        for output in outputs where output.portType == .headphones || output.portType == .bluetoothA2DP {
            return true
        }
        return false
    }
    
    // 타이머 기반 notification
    func scheduleTestNotification(for busAlert: BusAlert) {
        // 고유한 identifier 생성 (예: 알림의 ID)
        let identifier = busAlert.id
        
        let content = UNMutableNotificationContent()
        content.title = "\(busAlert.arrivalBusStopNm) \(busAlert.alertBusStop) 정거장 전입니다."
        content.subtitle = "일어나서 내릴 준비를 해야해요!"
        content.interruptionLevel = .timeSensitive // 설정할 interruption level
        
        // 이어폰이 연결되어 있는 경우에만 소리를 포함한 알림을 생성합니다.
        if isHeadphonesConnected() {
            content.sound = UNNotificationSound.default
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("silentSound.wav"))
        }
        
        // 10초 후 알림
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    func cancelAllNotifications(for busAlert: BusAlert) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("All notifications for \(busAlert.alertLabel) have been canceled")
    }
    
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Foreground 상태에서 알림 수신") // Foreground 상태에서 알림 수신 확인
        //        hapticManager.playPattern()
        notificationReceived = true // 알림 수신 상태 업데이트
        completionHandler([.list, .sound, .banner])
    }
    
    // 사용자가 Notification을 탭하면 호출되는 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("알림 수신")
        //        hapticManager.playPattern()
        notificationReceived = true // 알림 수신 상태 업데이트
        completionHandler()
    }
    
}
