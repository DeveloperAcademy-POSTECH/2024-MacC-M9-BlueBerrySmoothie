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
  
  // MARK: - SwfitData
    var modelContainer: ModelContainer = {
        // 1. Schema 생성
        let schema = Schema([Alert.self])
        
        // 2. Model 관리 규칙을 위한 ModelConfiguration 생성
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        // 3. ModelContainer 생성
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(busStopViewModel)
                .modelContainer(for: [BusAlert.self, BusStopLocal.self])
          .onAppear {
                    // 필요시 추가 초기화 작업
                    NotificationManager.instance.requestAuthorization() // 권한 요청 예시
                }
        }
        // 전역적으로 사용한 영구 데이터이기 때문에, WindowGroup에 주입
        .modelContainer(modelContainer)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // UNUserNotificationCenter의 delegate를 NotificationManager로 설정
        UNUserNotificationCenter.current().delegate = NotificationManager.instance
        
        return true
    }
}
