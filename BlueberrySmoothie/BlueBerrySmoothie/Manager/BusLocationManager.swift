import Foundation
import CoreLocation

class BusLocationManager: ObservableObject {
    @Published var busLocations: [BusLocation] = []
    private var timer: Timer?
    
    /// 사용자 위치와 가장 가까운 버스를 찾는 함수
    func findNearestBus(to userLocation: CLLocation) -> BusLocation? {
        guard !busLocations.isEmpty else { return nil }
        
        let nearestBus = busLocations.min(by: { (bus1, bus2) -> Bool in
            let location1 = CLLocation(latitude: bus1.latitude, longitude: bus1.longitude)
            let location2 = CLLocation(latitude: bus2.latitude, longitude: bus2.longitude)
            return location1.distance(from: userLocation) < location2.distance(from: userLocation)
        })
        
        return nearestBus
    }
    
    /// 실제 API 호출을 통해 버스 위치 데이터를 가져오는 함수
    func fetchBusLocationData() {
        // API 호출 코드 예시: URLSession을 사용하여 데이터를 가져옴
        // 이 부분은 실제 API에 맞춰 변경 필요
        let sampleBusLocations = [
            BusLocation(busID: "BusA", latitude: 37.5665, longitude: 126.9780),
            BusLocation(busID: "BusB", latitude: 37.5700, longitude: 126.9820),
            BusLocation(busID: "BusC", latitude: 37.5650, longitude: 126.9750)
        ]
        
        DispatchQueue.main.async {
            self.busLocations = sampleBusLocations
        }
    }
    
    /// 주기적으로 API 데이터를 업데이트하는 타이머 시작
    func startUpdatingBusLocations() {
        // 타이머를 설정하여 일정 주기(예: 60초)마다 fetchBusLocationData() 호출
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.fetchBusLocationData()
        }
        timer?.fire() // 앱 시작 시 즉시 호출
    }
    
    /// 주기적 업데이트를 중지하는 함수
    func stopUpdatingBusLocations() {
        timer?.invalidate()
        timer = nil
    }
    
    // 외부에서 버스 위치 데이터를 업데이트하는 함수 (예시)
    func updateBusLocations(newLocations: [BusLocation]) {
        busLocations = newLocations
    }
    
    deinit {
        stopUpdatingBusLocations()
    }
}
