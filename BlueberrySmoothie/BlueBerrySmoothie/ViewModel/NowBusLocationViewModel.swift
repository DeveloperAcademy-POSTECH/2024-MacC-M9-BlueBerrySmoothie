import Foundation
import SwiftUI
import CoreLocation
import Combine

class NowBusLocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var NowbusLocations: [NowBusLocation] = []
    @Published var closestBusLocation: NowBusLocation?
    var busAlert: BusAlert?
    private var cancellables = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private var isUpdatingLocation = false // 위치 업데이트 상태 추적
    @State private var liveActivityManager: LiveActivityManager? = nil
    var juju: Int = 1
   

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        print("NowBusLocationViewModel initialized.")
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        fetchBusLocationData(cityCode: 21, routeId: "BSB5200043000")
    }
    
    func startUpdating() {
        guard !isUpdatingLocation else { return } // 이미 활성 상태라면 무시
        locationManager.startUpdatingLocation()
        isUpdatingLocation = true
        print("Location updates started.")
    }

    func stopUpdating() {
        guard isUpdatingLocation else { return } // 이미 중지 상태라면 무시
        locationManager.stopUpdatingLocation()
        isUpdatingLocation = false
        print("Location updates stopped.")
    }

    deinit {
        stopUpdating()
        print("NowBusLocationViewModel deinitialized.")
    }

    // CLLocationManagerDelegate 메서드 - 사용자 위치 업데이트 시 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        print("locationManager(didUpdateLocations)")
        findClosestBusLocation()
    }

    // API를 호출하여 버스 위치 데이터를 가져옴
    func fetchBusLocationData(cityCode: Int, routeId: String) {
        fetchNowBusLocationData(cityCode: cityCode, routeId: routeId) { [weak self] locations in
            DispatchQueue.main.async {
                
                print("----------------------------------------------------------------")
                // 좌표 검증 후 업데이트
                self?.NowbusLocations = locations.map { self?.validateAndFixCoordinates(for: $0) ?? $0 }
              
                
//                self?.findClosestBusLocation() // 데이터 가져온 후 가장 가까운 버스 위치 계산
//                self?.printUserLocationAndClosestBus() // 사용자 위치 및 가장 가까운 버스 정보 출력
            }
        }
    }

    // 사용자 위치와 가장 가까운 버스 위치를 찾음
    private func findClosestBusLocation() {
        guard let userLocation = userLocation else { return }
        print("userLocation: \(userLocation)")

        closestBusLocation = NowbusLocations.min(by: { bus1, bus2 in
            let busLocation1 = CLLocation(latitude: Double(bus1.gpslati) ?? 0, longitude: Double(bus1.gpslong) ?? 0)
            let busLocation2 = CLLocation(latitude: Double(bus2.gpslati) ?? 0, longitude: Double(bus2.gpslong) ?? 0)

            return userLocation.distance(from: busLocation1) < userLocation.distance(from: busLocation2)
        })
        
        let currentDate = Date()  // 현재 시간을 가져옵니다.

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"  // 원하는 시간 포맷을 지정합니다.
        let formattedTime = formatter.string(from: currentDate)

        print(formattedTime)  // 예: 15:30:45
//          LiveActivityManager.shared.updateLiveActivity(progress: 0.5, currentStop: closestBusLocation?.nodenm ?? "로딩중", stopsRemaining: juju)
        LiveActivityManager.shared.updateLiveActivity(progress: 0.5, currentStop: closestBusLocation?.nodenm ?? "로딩중", stopsRemaining: Int(busAlert?.arrivalBusStopNord ?? 1) - (Int(closestBusLocation?.nodeord ?? "0") ?? 0) - 1, Updatetime: formattedTime)
        print("여기서 깔끔하게 업데이트")
        print(busAlert,"여기는 모델")
        print("가장 가까운 정류장: \(closestBusLocation?.nodenm)")
    }

    // 사용자 위치와 가장 가까운 버스 정보를 출력
    private func printUserLocationAndClosestBus() {
        if let userLocation = userLocation {
            print("사용자의 현재 위치: 위도 \(userLocation.coordinate.latitude), 경도 \(userLocation.coordinate.longitude)")
        } else {
            print("사용자 위치를 가져오지 못했습니다.")
        }

        if let closestBus = closestBusLocation {
            print("가장 가까운 버스 정보:")
            print("버스 위도: \(closestBus.gpslati), 경도: \(closestBus.gpslong)")
        } else {
            print("가까운 버스를 찾을 수 없습니다.")
        }
    }

    // 위도와 경도를 검증하고 필요한 경우 수정
    private func validateAndFixCoordinates(for busLocation: NowBusLocation) -> NowBusLocation {
        var correctedBusLocation = busLocation
        guard let latitude = Double(busLocation.gpslati),
              let longitude = Double(busLocation.gpslong) else {
            return correctedBusLocation
        }

        // 위도와 경도가 올바른지 확인 (대한민국 기준 위도는 약 33~38, 경도는 약 124~132)
        if latitude < 20 || latitude > 40 || longitude < 110 || longitude > 140 {
            // 위도와 경도가 뒤바뀐 경우 수정
            correctedBusLocation.gpslati = String(longitude)
            correctedBusLocation.gpslong = String(latitude)
        }

        return correctedBusLocation
    }
}
 
