//
//  BlueBerrySmoothieApp.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/30/24.
////
//
//import SwiftUI
//import SwiftData
//
//@main
//
//struct BlueBerrySmoothieApp: App {
//    @StateObject private var busStopViewModel = BusStopViewModel()// AppDelegate 역할 클래스와 연결
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//
//    var body: some Scene {
//        WindowGroup {
//            SplashView()
//                .environmentObject(busStopViewModel)
//                .modelContainer(for: [BusAlert.self, BusStopLocal.self])
////          .onAppear {
////                    // 필요시 추가 초기화 작업
////                    NotificationManager.instance.requestAuthorization() // 권한 요청 예시
////                }
//        }
//
//    }
//}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        
//        // UNUserNotificationCenter의 delegate를 NotificationManager로 설정
//        UNUserNotificationCenter.current().delegate = NotificationManager.instance
//        
//        return true
//    }
//    
//    
//}
import SwiftUI
import UIKit

@main
struct BlueBerrySmoothieApp: App {
    @StateObject private var busStopViewModel = BusStopViewModel() // ViewModel 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // AppDelegate 연결

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(busStopViewModel)
                .modelContainer(for: [BusAlert.self, BusStopLocal.self])
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // 앱이 시작될 때 호출
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Background Fetch 설정
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
//        print("Background Fetch 및 Location Updates 설정 완료.")
        
        // 푸시 알림 관련 설정
        UNUserNotificationCenter.current().delegate = NotificationManager.instance
        
        return true
    }
    
    // Background Fetch 메서드
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let viewModel = NowBusLocationViewModel() // NowBusLocationViewModel 인스턴스 생성
        viewModel.fetchBusLocationData(cityCode: 21, routeId: "BSB5200043000") // API 호출

        // Background 작업이 끝난 후 호출 (성공 시 .newData)
        completionHandler(.newData)
    }
}
