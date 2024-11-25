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
                        .foregroundColor(.orange)
                        .fontWeight(.bold)
                    
                    Spacer()
                    Text("등교알람") // 앱 이름
                        .font(.subheadline) // 작은 글씨체 설정
                        .fontWeight(.light) // 얇은 글씨체 설정
                        .foregroundColor(.orange)
                }
                .padding(.bottom, 5)

                Text("알람까지 \(context.state.stopsRemaining) 정거장 남았습니다.") // 남은 정류장
                    .font(.title3) // 글씨 크기를 크게 설정
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading) {
                                   Text("현재 정류장은")
                                       .font(.subheadline)
                                       .foregroundColor(.gray)
                                   Text("\(context.state.currentStop)입니다.") // 현재 정류장 + "입니다."
                                       .font(.subheadline)
                                       .foregroundColor(.orange) // 주황색으로 설정
                               }
                               .padding(.bottom, 5)
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
}
