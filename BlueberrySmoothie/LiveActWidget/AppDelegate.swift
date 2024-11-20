//import UIKit
//import ActivityKit

//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // 라이브 액티비티 상태 업데이트
//        updateLiveActivity(progress: 0.5)
//    }
//    func applicationDidBecomeActive(_ application: UIApplication) {
//            // 앱이 활성화될 때 호출
//            if let currentActivity = Activity<MyLiveActivityAttributes>.activities.first {
//                print("Live Activity is active with ID: \(currentActivity.id)")
//            } else {
//                print("No active Live Activity.")
//            }
//        }
//    }
//
//    func updateLiveActivity(progress: Double) {
//        guard let activity = Activity<MyLiveActivityAttributes>.activities.first else { return }
//
//        let newState = MyLiveActivityAttributes.ContentState(progress: progress)
//
//        Task {
//            do {
//                try await activity.update(using: newState)
//            } catch {
//                print("Failed to update live activity: \(error)")
//            }
//        }
//    }
//
//
