import SwiftUI
import WidgetKit
import ActivityKit

struct LiveActivityUI: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyLiveActivityAttributes.self) { context in
            // 잠금 화면 및 홈 화면 표시 내용
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bus") // 아이콘
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 8)

                    Text("Hotcha") // 앱 이름
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 5)

                
// 여기 봐주세요..!
                Text("현재 정류장: \(context.state.currentStop)") // 현재 정류장 정보
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)

                Text("알람까지 \(context.state.stopsRemaining) 정거장 남았습니다.") // 남은 정류장
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)

                VStack {
                    Text(progressMessage(for: context.state.progress)) // 진행 상태 메시지
                        .font(.headline)
                        .foregroundColor(.blue)
                        .fontWeight(.bold)

                    ProgressView(value: context.state.progress, total: 1.0) // 진행 상태 바
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 10)
                        .accentColor(.blue)
                        .padding(.top, 5)
                }
                .padding()
            }
            .padding()
        } dynamicIsland: { context in
            // Dynamic Island 표시 내용
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "bus") // 아이콘
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 5)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.stopsRemaining) 정거장 전") // 남은 정류장
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text("현재 정거장: \(context.state.currentStop)") // 현재 정류장
                        .font(.body)
                        .foregroundColor(.primary)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Text("Hotcha와 함께 안전한 하차를!") // 메시지
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } compactLeading: {
                Image(systemName: "bus") // 간단한 아이콘
            } compactTrailing: {
                Text("\(context.state.stopsRemaining) 정거장 전") // 정류장 정보
                    .font(.caption)
                    .foregroundColor(.secondary)
            } minimal: {
                Image(systemName: "bus") // 최소 아이콘
            }
        }
    }

    // 진행 상태 메시지 반환
    func progressMessage(for progress: Double) -> String {
        switch progress {
        case 1.0:
            return "하차 완료"
        case 0.75..<1.0:
            return "하차 준비"
        case 0.5..<0.75:
            return "목적지 임박"
        case 0.25..<0.5:
            return "다음 정류장까지"
        default:
            return "진행 중"
        }
    }
}

// 라이브 액티비티 관리 클래스
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
                content: .init(state: initialState, staleDate: nil)
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
                try await activity.update(using: .init(from: newState as! Decoder))
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
