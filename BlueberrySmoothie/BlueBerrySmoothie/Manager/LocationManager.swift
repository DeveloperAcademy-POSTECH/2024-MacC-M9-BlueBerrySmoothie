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
    
    private var notificationTimer: Timer?
    private var activeAlarms: Set<String> = [] // 활성화된 알람을 추적하기 위한 Set
    private var activeBusAlerts: [String: BusAlert] = [:] // 현재 모니터링 중인 BusAlert를 저장하는 Dictionary
    
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
        manager.pausesLocationUpdatesAutomatically = false // 백그라운드에서 업데이트가 중지되지 않도록 설정
        checkIfLocationServicesIsEnabled()
    }
    
    func startLocationUpdates(for busAlert: BusAlert, for busStopLocal: BusStopLocal) {
        // Region Monitoring 설정
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: busStopLocal.gpslati, longitude: busStopLocal.gpslong),
            radius: 20.0,
            identifier: busAlert.id)
        
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        // 현재 모니터링 중인 모든 region 제거
        manager.monitoredRegions.forEach { manager.stopMonitoring(for: $0) }
        
        // 새로운 region 모니터링 시작
        manager.startMonitoring(for: region)
        manager.startUpdatingLocation()
        
        print("Started monitoring region for \(busAlert.alertLabel ?? "")")
    }
    
    func stopLocationUpdates(for busAlert: BusAlert) {
        manager.monitoredRegions.forEach { region in
            if region.identifier == busAlert.id {
                manager.stopMonitoring(for: region)
            }
        }
        stopNotificationAlarm(for: busAlert)
    }
    
    // Region 진입 시 호출되는 delegate 메서드
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region: \(region.identifier)")
        if let busAlert = getBusAlert(for: region.identifier) {
            startNotificationAlarm(for: busAlert)
        }
    }
    
    func startNotificationAlarm(for busAlert: BusAlert) {
        guard !activeAlarms.contains(busAlert.id) else { return }
        activeAlarms.insert(busAlert.id)
        
        // 백그라운드에서도 동작하는 로컬 알림 예약
        let content = UNMutableNotificationContent()
        content.title = busAlert.alertLabel ?? "알림"
        content.body = "목적지에 도착했습니다."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.5, repeats: true)
        let request = UNNotificationRequest(identifier: busAlert.id,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func stopNotificationAlarm(for busAlert: BusAlert) {
        activeAlarms.remove(busAlert.id)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [busAlert.id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [busAlert.id])
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
    
    // BusAlert 등록 메서드
    func registerBusAlert(_ busAlert: BusAlert, busStopLocal: BusStopLocal) {
        activeBusAlerts[busAlert.id] = busAlert
        startLocationUpdates(for: busAlert, for: busStopLocal)
    }
    
    // BusAlert 등록 해제 메서드
    func unregisterBusAlert(_ busAlert: BusAlert) {
        activeBusAlerts.removeValue(forKey: busAlert.id)
        stopLocationUpdates(for: busAlert)
    }
    
    // BusAlert 조회 메서드
    private func getBusAlert(for identifier: String) -> BusAlert? {
        return activeBusAlerts[identifier]
    }
    
    // 모든 모니터링 중지
    func stopAllMonitoring() {
        activeBusAlerts.forEach { (_, busAlert) in
            stopLocationUpdates(for: busAlert)
        }
        activeBusAlerts.removeAll()
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

