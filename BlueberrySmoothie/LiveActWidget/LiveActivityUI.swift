import SwiftUI
import WidgetKit
import ActivityKit

struct LiveActivityUI: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyLiveActivityAttributes.self) { context in
            // Lock Screen 및 Home Screen에서 표시되는 내용
            VStack {
                Text(context.attributes.title)  // 타이틀 표시
                    .font(.headline)
                Text(context.attributes.description)  // 설명 표시
                    .font(.subheadline)
                ProgressView(value: context.state.progress, total: 1.0)  // 진행 상태 표시
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
            }
        } dynamicIsland: { context in
            // Dynamic Island에서 표시되는 내용
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("타이틀: \(context.attributes.title)")  // 타이틀
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("상태: \(Int(context.state.progress * 100))%")  // 진행 상태 (백분율로 표시)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text("진행 중...")  // 간단한 메시지
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("bottom island")
                }
            } compactLeading: {
                Text("진행: \(Int(context.state.progress * 100))%")  // 간단한 진행 상태 표시
            } compactTrailing: {
                Text("상태: \(context.state.progress == 1.0 ? "완료" : "진행 중")")  // 완료 여부 표시
            } minimal: {
                Text("진행 중")  // 최소 상태 표시
            }
        }
    }
}
