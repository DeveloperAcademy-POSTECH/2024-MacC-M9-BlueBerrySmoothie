import ActivityKit


struct MyLiveActivityAttributes: ActivityAttributes {
    // 공통 속성 정의 (예: 제목, 설명 등)
    public struct ContentState: Codable, Hashable {
        var progress: Double // 진행률
        var currentStop: String // 현재 정류장
        var stopsRemaining: Int // 남은 정류장 수
    }

    // 라이브 액티비티의 일반적인 속성 (변하지 않는 값)
    var title: String // 제목
    var description: String // 설명
}
