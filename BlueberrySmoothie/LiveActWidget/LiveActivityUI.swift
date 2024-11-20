import SwiftUI
import WidgetKit


struct LiveActivityUI: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyLiveActivityAttributes.self) { context in
            // Create the presentation that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            // ...
            Text("정상 작동!")
        } dynamicIsland: { context in
            // Create the presentations that appear in the Dynamic Island.
            DynamicIsland {
                // Create the expanded presentation.
                // ...
                DynamicIslandExpandedRegion(.leading) {
                    
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    
                }
                DynamicIslandExpandedRegion(.center) {
                    
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("bottom island")
                    
                }
            } compactLeading: {
                Text("부산역")
                
            } compactTrailing: {
                Text("3정거장 전")
                
            } minimal: {
                Text("정상 작동!")
            }
        }
    }
}
