//
//  LocationManager.swift
//  MapkitTest
//
//  Created by 문호 on 10/24/24.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let notificationManager = NotificationManager.instance
    static let shared = LocationManager() // 싱글톤 인스턴스
    let manager = CLLocationManager()
    private var timer: Timer?
    private var notificationTimer: Timer?
    private var activeAlarms: Set<String> = []// 활성화된 알람을 추적하기 위한 Set

    
    @Published var location: CLLocation?
    @Published var region: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var errorMessage: String?
    @Published var lastRefreshTime: Date = Date()
    
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // locationManager의 정확도를 최고로 설정
        manager.allowsBackgroundLocationUpdates = true // 백그라운드에서도 위치를 업데이트하도록 설정
        checkIfLocationServicesIsEnabled()
        print("init은 언제호출")
    }
    
    // 위치 업데이트 시작 함수
    func startLocationUpdates(for busAlert: BusAlert, for busStopLocal: BusStopLocal) {
        print("Starting location updates: \(busAlert.alertLabel)")
        manager.startUpdatingLocation()
        startAutoRefresh(for: busAlert, for: busStopLocal) // 위치 자동 갱신 타이머 시작
    }
    
    // 위치 업데이트 중지 함수
    func stopLocationUpdates(for busAlert: BusAlert) {
        print("Stopping location updates: \(busAlert.alertLabel)")
        manager.stopUpdatingLocation()
        stopAutoRefresh() // 위치 자동 갱신 타이머 중지
        stopNotificationAlarm(for: busAlert)
    }
    
    /// 6초마다 refreshLocation()을 호출하는 타이머를 설정
    func startAutoRefresh(for busAlert: BusAlert, for busStopLocal: BusStopLocal) {
        timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { [weak self] _ in
            self?.refreshLocation(for: busAlert, for: busStopLocal)
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
    func refreshLocation(for busAlert: BusAlert, for busStopLocal: BusStopLocal) {
        lastRefreshTime = Date()
//                manager.startUpdatingLocation()
        print("현재 내 위치: \(manager.location)" ?? "실시간 location")
        
        let targetRegion = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: busStopLocal.gpslati, longitude: busStopLocal.gpslong),
//            center: CLLocationCoordinate2D(latitude: 36.014141, longitude: 129.325686), // 테스트 좌표(c5 입구)
            radius: 15.0,
            identifier: "POIRegion")
        
        // 위치가 region 안에 있는지 확인
        if let currentLocation = manager.location {
            if targetRegion.contains(currentLocation.coordinate) {
                print("targetRegion = \(targetRegion)")
                print("현재 위치가 지정된 지역 안에 있습니다.")
                startNotificationAlarm(for: busAlert) //1.5초마다 알림을 생성합니다.
            } else {
                print("targetRegion = \(targetRegion)")
                print("현재 위치가 지정된 지역 밖에 있습니다.")
            }
        }
    }

    func startNotificationAlarm(for busAlert: BusAlert) {
            guard !activeAlarms.contains(busAlert.id) else { return }
            
            activeAlarms.insert(busAlert.id)
            
            notificationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
                guard let self = self,
                      self.activeAlarms.contains(busAlert.id) else {
                    self?.stopNotificationAlarm(for: busAlert)
                    return
                }
                self.notificationManager.scheduleTestNotification(for: busAlert)
            }
            
            // RunLoop에 타이머 추가
            if let timer = notificationTimer {
                RunLoop.current.add(timer, forMode: .common)
            }
            
            print("Notification alarm started for \(busAlert.alertLabel ?? "Unknown")")
        }

    // 알림 중지
        func stopNotificationAlarm(for busAlert: BusAlert) {
            activeAlarms.remove(busAlert.id)
            notificationTimer?.invalidate()
            notificationTimer = nil
            cancelAllNotifications(for: busAlert)
            print("Notification alarm stopped for \(busAlert.alertLabel ?? "Unknown")")
        }
    
    // 모든 알림 취소
        private func cancelAllNotifications(for busAlert: BusAlert) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            print("All notifications canceled for \(busAlert.alertLabel ?? "Unknown")")
        }
    
    // 현재 알람이 활성화되어 있는지 확인
        func isAlarmActive(for busAlert: BusAlert) -> Bool {
            return activeAlarms.contains(busAlert.id)
        }
    
    // 모든 알람 중지
        func stopAllAlarms() {
            activeAlarms.removeAll()
            notificationTimer?.invalidate()
            notificationTimer = nil
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            print("All alarms stopped")
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

extension LocationManager: CLLocationManagerDelegate {
    
    /// 위치가 업데이트될 때마다 호출되는 함수
    /// 위치가 유효한 경우(horizontalAccuracy > 0), 위치 데이터를 저장하고, CLGeocoder를 통해 주소를 역지오코딩하여 address와 detailedAddress를 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if location.horizontalAccuracy > 0 {
            self.location = location
            self.region = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.manager.stopUpdatingLocation()
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

