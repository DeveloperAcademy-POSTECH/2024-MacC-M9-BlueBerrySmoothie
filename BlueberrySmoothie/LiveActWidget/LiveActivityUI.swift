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
                        .foregroundColor(.brand) // 라이트 모드 및 다크 모드에서 모두 주황색
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("등교알람")
                        .font(.subheadline) // 글씨 크기 설정
                        .fontWeight(.light) // 얇은 글씨체 설정
                        .foregroundColor(.brand) // 텍스트 색상 설정
                        .padding(8) // 텍스트 주변 여백 설정
                        .background(
                            RoundedRectangle(cornerRadius: 8) // 둥근 모서리 사각형
                                .fill(Color.lightbrand.opacity(0.2)) // 반투명 배경색
                        )

                                   }
                .padding(.bottom, 5)

                Text("알람까지 \(context.state.stopsRemaining) 정거장 남았습니다.") // 남은 정류장
                                    .font(.title3) // 글씨 크기를 크게 설정
                                    .foregroundColor(
                                        Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black })
                                    ) // 다크 모드일 때 하얀색, 라이트 모드일 때 검은색
                                    .padding(.bottom, 10)
                
                VStack(alignment: .leading) {
                    Text("현재 정류장은")
                        .font(.subheadline)
                        .foregroundColor(.gray1)
                    Text("\(context.state.currentStop)입니다.") // 현재 정류장 + "입니다."
                        .font(.subheadline)
                        .foregroundColor(.brand)
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

                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Text("현재 정류장:")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text("\(context.state.currentStop)") // 현재 정류장 + "입니다."
                            .font(.subheadline)
                            .foregroundColor(.brand)
                        Text("입니다")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    
                    
                    Spacer()
//                    Text("현재 정류장: \(context.state.currentStop)") // 현재 정류장
//                        .font(.body)
//                        .foregroundColor(.primary)  // 기본 색상 (다크/라이트 모드 자동 처리)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Text("Hotcha와 함께 하차를!")
                        .font(.caption)
                        .foregroundColor(.midbrand)
                        .padding(.top, 10)
                }
            } compactLeading: {
                Image("AppIcon")
            } compactTrailing: {
                Text("\(context.state.stopsRemaining) 정거장 전")
                    .font(.body)
                    .fontWeight(.bold)  // 볼드체 설정
                    .foregroundColor(.white)  // 흰색 텍스트
            } minimal: {
                Image("AppIcon")
            }
        }
    }
}
