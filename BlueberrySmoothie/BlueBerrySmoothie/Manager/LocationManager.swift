//
//  LocationManager.swift
//  MapkitTest
//
//  Created by 문호 on 10/24/24.
//

import SwiftUI
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject {
    static let instance = LocationManager() //Singleton 인스턴스 생성
    let manager = CLLocationManager()
    private var timer: Timer?
    
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), //초기화 값.업데이트 시, 실제 사용자 위치로 업데이트 됨
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)  // 배율 확대
    )
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var address: String = "위치 찾는 중..."
    @Published var detailedAddress: AddressDetail = AddressDetail()
    @Published var errorMessage: String?
    @Published var lastRefreshTime: Date = Date()
    
    private let targetRegion = CLCircularRegion(
        center: CLLocationCoordinate2D(latitude: 36.017449, longitude: 129.322232), //기숙사
        //        center: CLLocationCoordinate2D(latitude: 36.015175, longitude: 129.325121), //포스텍 버스정류장(기숙사 맞은편)
        radius: 4.0,
        identifier: "POIRegion")
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // locationManager의 정확도를 최고로 설정
        manager.allowsBackgroundLocationUpdates = true // 백그라운드에서도 위치를 업데이트하도록 설정
        checkIfLocationServicesIsEnabled()
    }
    
    // 위치 업데이트 시작 함수
    func startLocationUpdates() {
        print("Starting location updates")
        manager.startUpdatingLocation()
        startAutoRefresh() // 위치 자동 갱신 타이머 시작
    }
    
    // 위치 업데이트 중지 함수
    func stopLocationUpdates() {
        print("Stopping location updates")
        manager.stopUpdatingLocation()
        stopAutoRefresh() // 위치 자동 갱신 타이머 중지
    }
    
    /// 10초마다 refreshLocation()을 호출하는 타이머를 설정
    func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { [weak self] _ in
            self?.refreshLocation()
        }
    }
    
    /// 타이머를 중지하고 해제
    func stopAutoRefresh() {
        //        timer?.invalidate()
        //        timer = nil
        if timer != nil {
            print("Auto refresh timer invalidated")
            timer?.invalidate()
            timer = nil
        }
    }
    
    /// 위치 업데이트를 시작하고, 현재 위치가 targetRegion 안에 있는지 확인해 결과를 콘솔에 출력합니다.
    func refreshLocation() {
        address = "위치 찾는 중…"
        lastRefreshTime = Date()
        //        manager.startUpdatingLocation()
        print(manager.location ?? "실시간 location")
        
        // 위치가 region 안에 있는지 확인
        if let currentLocation = manager.location {
            if targetRegion.contains(currentLocation.coordinate) {
                print("현재 위치가 지정된 지역 안에 있습니다.")
            } else {
                print("현재 위치가 지정된 지역 밖에 있습니다.")
            }
        }
    }
    
    /// 위치 서비스가 활성화되었는지 확인하고, 활성화되지 않았을 경우 오류 메시지를 설정
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            checkLocationAuthorization()
        } else {
            errorMessage = "위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 켜주세요."
        }
    }
    
    /// 현재 위치 권한 상태를 확인하고, 권한이 없을 경우 요청
    private func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            errorMessage = "위치 서비스 접근이 제한되어 있습니다."
        case .denied:
            errorMessage = "위치 서비스 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
        case .authorizedAlways, .authorizedWhenInUse:
            //            manager.startUpdatingLocation()
            manager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}

// 주소 세부 정보를 저장하는 구조체
struct AddressDetail {
    var country: String = ""
    var administrativeArea: String = ""  // 시/도
    var locality: String = ""            // 시/군/구
    var subLocality: String = ""         // 동/읍/면
    var thoroughfare: String = ""        // 도로명
    var subThoroughfare: String = ""     // 건물번호
    
    var fullAddress: String {
        [country, administrativeArea, locality, subLocality, thoroughfare, subThoroughfare]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var shortAddress: String {
        [locality, subLocality, thoroughfare, subThoroughfare]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    /// 위치가 업데이트될 때마다 호출되는 함수
    /// 위치가 유효한 경우(horizontalAccuracy > 0), 위치 데이터를 저장하고, CLGeocoder를 통해 주소를 역지오코딩하여 address와 detailedAddress를 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if location.horizontalAccuracy > 0 {
            self.location = location
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)  // 배율 확대
            )
            self.manager.stopUpdatingLocation()
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    self?.address = "주소를 찾을 수 없습니다."
                    return
                }
                
                if let placemark = placemarks?.first {
                    DispatchQueue.main.async {
                        var newAddress = AddressDetail()
                        newAddress.country = placemark.country ?? ""
                        newAddress.administrativeArea = placemark.administrativeArea ?? ""
                        newAddress.locality = placemark.locality ?? ""
                        newAddress.subLocality = placemark.subLocality ?? ""
                        newAddress.thoroughfare = placemark.thoroughfare ?? ""
                        newAddress.subThoroughfare = placemark.subThoroughfare ?? ""
                        
                        self?.detailedAddress = newAddress
                        self?.address = newAddress.fullAddress
                    }
                }
            }
        }
    }
    
    /// 위치 갱신 실패 시 오류 메시지를 설정하고 콘솔에 출력
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        errorMessage = "위치를 찾을 수 없습니다: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        checkLocationAuthorization()
    }
}

