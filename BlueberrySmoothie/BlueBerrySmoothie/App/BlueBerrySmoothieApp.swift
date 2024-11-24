//
//  BlueBerrySmoothieApp.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/30/24.
//

import SwiftUI
import SwiftData

@main

struct BlueBerrySmoothieApp: App {
    @StateObject private var busStopViewModel = BusStopViewModel()// AppDelegate 역할 클래스와 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
//            MainView()
//                .environmentObject(busStopViewModel)
//                .modelContainer(for: [BusAlert.self, BusStopLocal.self])
//          .onAppear {
//                    // 필요시 추가 초기화 작업
//                    NotificationManager.instance.requestAuthorization() // 권한 요청 예시
//                }
            CitySettingView()
        }

    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // UNUserNotificationCenter의 delegate를 NotificationManager로 설정
        UNUserNotificationCenter.current().delegate = NotificationManager.instance
        
        return true
    }
}
