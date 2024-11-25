
import ActivityKit
import Foundation

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private init() {}

    private var currentActivity: Activity<MyLiveActivityAttributes>?

    // 라이브 액티비티 시작
    func startLiveActivity(stationName: String, initialProgress: Double, currentStop: String, stopsRemaining: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("라이브 액티비티 실행 불가: 권한이 비활성화되어 있습니다.")
            return
        }

        let activityAttributes = MyLiveActivityAttributes(
            title: "Tracking Progress",
            description: "Your journey is in progress"
        )

        let initialState = MyLiveActivityAttributes.ContentState(
            progress: initialProgress,
            currentStop: currentStop,
            stopsRemaining: stopsRemaining
        )

        do {
            let activity = try Activity<MyLiveActivityAttributes>.request(
                attributes: activityAttributes,
                content: .init(state: initialState, staleDate: Date().addingTimeInterval(3600)) // 1시간 만료
            )
            currentActivity = activity
            print("라이브 액티비티 시작됨: \(activity.id)")
        } catch {
            print("라이브 액티비티 시작 실패: \(error.localizedDescription)")
        }
    }

    // 라이브 액티비티 상태 업데이트
    func updateLiveActivity(progress: Double, currentStop: String, stopsRemaining: Int) {
        guard let activity = currentActivity else {
            print("활동이 시작되지 않았습니다.")
            return
        }

        let newState = MyLiveActivityAttributes.ContentState(
            progress: progress,
            currentStop: currentStop,
            stopsRemaining: stopsRemaining
        )

        Task {
            do {
                try await activity.update(using: newState)
                print("라이브 액티비티 업데이트 완료: \(progress)")
            } catch {
                print("라이브 액티비티 업데이트 실패: \(error.localizedDescription)")
            }
        }
    }

    // 라이브 액티비티 종료
    func endLiveActivity() {
        guard let activity = currentActivity else {
            print("활동이 시작되지 않았습니다.")
            return
        }

        Task {
            do {
                await activity.end(dismissalPolicy: .immediate)
                print("라이브 액티비티 종료됨: \(activity.id)")
                currentActivity = nil
            } catch {
                print("라이브 액티비티 종료 실패: \(error.localizedDescription)")
            }
        }
    }
}
