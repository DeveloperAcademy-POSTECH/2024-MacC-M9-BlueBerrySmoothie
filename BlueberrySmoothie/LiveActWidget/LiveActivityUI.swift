import SwiftUI
import WidgetKit
import ActivityKit

struct LiveActivityUI: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyLiveActivityAttributes.self) { context in
            // Lock Screen 및 Home Screen에서 표시되는 내용
            VStack(alignment: .leading) {
                Text(context.attributes.title)  // 타이틀 표시 (예: "버스 하차 알림")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                Text(context.attributes.description)  // 설명 표시 (예: "다음 정류장까지...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)

                // 일자형 진행 상태 표시
                VStack {
                    Text(progressMessage(for: context.state.progress))  // 진행 상태 메시지 표시
                        .font(.headline)
                        .foregroundColor(.blue)
                        .fontWeight(.bold)

                    ProgressView(value: context.state.progress, total: 1.0)  // 진행 상태 바
                        .progressViewStyle(LinearProgressViewStyle())  // 일자형 스타일
                        .frame(height: 10)  // 진행 바 높이 설정
                        .accentColor(.blue)  // 진행 바 색상
                        .padding(.top, 5)
                }
                .padding()
            }
            .padding()
        } dynamicIsland: { context in
            // Dynamic Island에서 표시되는 내용
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("타이틀: \(context.attributes.title)")  // 타이틀
                        .font(.body)
                        .foregroundColor(.primary)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(progressMessage(for: context.state.progress))  // 상태 메시지 표시
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text("진행 중...")  // 간단한 메시지
                        .font(.body)
                        .italic()
                        .foregroundColor(.blue)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Text("bottom island")  // 아래쪽 추가 텍스트
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } compactLeading: {
                Text(progressMessage(for: context.state.progress))  // 간단한 진행 상태 표시
                    .font(.caption)
                    .foregroundColor(.primary)
            } compactTrailing: {
                Text("상태: \(context.state.progress == 1.0 ? "하차 완료" : "진행 중")")  // 완료 여부 표시
                    .font(.caption)
                    .foregroundColor(.secondary)
            } minimal: {
                Text("진행 중")  // 최소 상태 표시
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }

    // 버스 하차 알림에 맞춘 상태 메시지 반환
    func progressMessage(for progress: Double) -> String {
        switch progress {
//        case 0.0:
//            return "버스 탑승 중"
        case 1.0:
            return "하차 완료"
        case 0..<0.25:
            return "다음 정류장까지"
        case 0.25..<0.5:
            return "목적지 임박"
        case 0.5..<0.75:
            return "하차 준비"
        default:
            return "하차 완료"
        }
    }
}
