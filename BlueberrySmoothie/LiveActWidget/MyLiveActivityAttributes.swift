import ActivityKit

// MyLiveActivityAttributes 정의
struct MyLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var progress: Double  // 진행 상태 (예: 0.0에서 1.0까지)
        
    }
    
    var title: String  // 타이틀 (예: "Tracking Progress")
    var description: String  // 설명 (예: "Your journey is in progress")
   }

