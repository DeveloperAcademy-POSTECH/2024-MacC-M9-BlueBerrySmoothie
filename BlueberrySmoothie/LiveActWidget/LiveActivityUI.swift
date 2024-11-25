import SwiftUI
import WidgetKit
import ActivityKit

struct LiveActivityUI: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyLiveActivityAttributes.self) { context in
            // 잠금 화면 및 홈 화면 표시 내용
            VStack(alignment: .leading) {
                HStack {
                    Image("AppIcon") // 앱 아이콘
                        .resizable()
                        .frame(width: 24, height: 24)
                        .cornerRadius(4) // 아이콘 모서리 둥글게 처리
                        .padding(.trailing, 8)

                    Text("핫챠") // 앱 이름
                        .font(.headline) // 헤드라인 글씨체
//                        .fontWeight(.light) // 얇은 글씨체 설정
                        .foregroundColor(.orange)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    Text("등교알람") // 앱 이름
                        .font(.headline) // 헤드라인 글씨체
                        .fontWeight(.light) // 얇은 글씨체 설정
                        .foregroundColor(.orange)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 5)

                Text("알람까지 \(context.state.stopsRemaining) 정거장 남았습니다.") // 남은 정류장
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                
                Text("현재 정류장은 \(context.state.currentStop)입니다.") // 현재 정류장 정보
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)

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
                    Image("AppIcon") // 아이콘
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 5)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.stopsRemaining) 정거장 전") // 남은 정류장
                        .font(.body)
                                .fontWeight(.bold)  // 볼드체 설정
                                .foregroundColor(.white)  // 하얀색 텍스트로 설정
                }

                DynamicIslandExpandedRegion(.center) {
                    Text("현재 정류장: \(context.state.currentStop)") // 현재 정류장
                        .font(.body)
                        .foregroundColor(.primary)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Text("Hotcha와 함께 하차를!") // 메시지
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } compactLeading: {
                Image("AppIcon")
            } compactTrailing: {
                Text("\(context.state.stopsRemaining) 정거장 전")
                    .font(.body)
                            .fontWeight(.bold)  // 볼드체 설정
                            .foregroundColor(.white)  // 하얀색 텍스트로 설정

            } minimal: {
                Image("AppIcon")
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
