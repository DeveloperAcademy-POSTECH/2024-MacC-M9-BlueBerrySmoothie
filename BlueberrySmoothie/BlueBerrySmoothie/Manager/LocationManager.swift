//
//  LocationManager.swift
//  MapkitTest
//
//  Created by 문호 on 10/24/24.
//

import SwiftUI
import CoreLocation
import AVFoundation
import MediaPlayer

class LocationManager: NSObject, ObservableObject {
    private let notificationManager = NotificationManager.instance
    static let shared = LocationManager() // 싱글톤 인스턴스
    let manager = CLLocationManager()
    private var activeBusAlerts: [String: BusAlert] = [:]
    private var backgroundTasks: [String: UIBackgroundTaskIdentifier] = [:]
    private var notificationTimers: [String: Timer] = [:]
    private var activeAlarms: Set<CLCircularRegion> = [] // 활성화된 알람을 CLCircularRegion으로 추적

    private var player: AVAudioPlayer?
    private var originalVolume: Float = 0.0
    private let volumeView = MPVolumeView()
    
    @Published var location: CLLocation?
    @Published var region: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var errorMessage: String?
    @Published var lastRefreshTime: Date = Date()
    @Published var activeNotifications: Set<String> = [] // 현재 활성화된 알림 추적
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // locationManager의 정확도를 최고로 설정
        manager.allowsBackgroundLocationUpdates = true // 백그라운드에서도 위치를 업데이트하도록 설정
        manager.pausesLocationUpdatesAutomatically = false // 백그라운드에서 업데이트가 중지되지 않도록 설정
        setupAudioSession()
        loadAudioFile()
        checkIfLocationServicesIsEnabled()
    }
    
    // LocationManager.swift
    func triggerAlarm(for busAlert: BusAlert) {
        // 알람을 시작하도록 기존의 startNotifications(for:) 메서드를 호출
        startNotifications(for: busAlert)
    }

    /// 정류장 근처에 왔을 때 실행되는 함수
    private func startNotifications(for busAlert: BusAlert) {
        guard !activeNotifications.contains(busAlert.id) else { return }
        
        // 이전 타이머가 있다면 중지
        stopNotifications(for: busAlert)
        
        // 활성 알림 목록에 추가
        activeNotifications.insert(busAlert.id)
        
        // 백그라운드 작업 시작
        let backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.stopNotifications(for: busAlert)
        }
        backgroundTasks[busAlert.id] = backgroundTask
        
        // 0.6초마다 반복되는 타이머 생성
        let timer = Timer(timeInterval: 0.6, repeats: true) { [weak self] _ in
            self?.scheduleNotification(for: busAlert)
        }
        RunLoop.main.add(timer, forMode: .common)
        notificationTimers[busAlert.id] = timer
        
        print("Started notifications for \(busAlert.alertLabel ?? "")")
    }
    
    func stopNotifications(for busAlert: BusAlert) {
        // 타이머 중지
        notificationTimers[busAlert.id]?.invalidate()
        notificationTimers.removeValue(forKey: busAlert.id)
        
        // 활성 알림 목록에서 제거
        activeNotifications.remove(busAlert.id)
        
        // 백그라운드 작업 종료
        if let backgroundTask = backgroundTasks[busAlert.id] {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTasks.removeValue(forKey: busAlert.id)
        }
        
        // 대기 중인 알림 제거
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [busAlert.id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [busAlert.id])
        
        print("Stopped notifications for \(busAlert.alertLabel ?? "")")
    }
    
    private func scheduleNotification(for busAlert: BusAlert) {
        let content = UNMutableNotificationContent()
        content.title = "\(busAlert.arrivalBusStopNm) \(busAlert.alertBusStop)정거장 전입니다."
        content.body = "일어나서 내릴 준비를 해야해요!"
        
        let isHeadphonesConnected = {
            let audioSession = AVAudioSession.sharedInstance()
            let outputs = audioSession.currentRoute.outputs
            for output in outputs where output.portType == .headphones || output.portType == .bluetoothA2DP {
                return true
            }
            return false
        }()
        
        if isHeadphonesConnected {
            content.sound = .default
            playAudio()
        } else {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("silentSound.wav"))
        }
        
        
        // 앱이 포그라운드 상태일 때
        if UIApplication.shared.applicationState == .active {
            content.subtitle = "포그라운드 알림"
        } else {
            content.subtitle = "백그라운드 알림"
        }
        
        // 고유한 식별자 생성 (시간값 포함)
        let identifier = "\(busAlert.id)_\(Date().timeIntervalSince1970)"
        
        // 즉시 실행되는 트리거
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.4, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    // 버스 알람 등록 (모니터링 지역 설정, 시작)
    func registerBusAlert(_ busAlert: BusAlert, busStopLocal: BusStopLocal) {
        activeBusAlerts[busAlert.id] = busAlert
        
        // Region Monitoring 설정
        let region1 = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: busStopLocal.gpslati, longitude: busStopLocal.gpslong),
            radius: 70.0, // 70m 반경
            identifier: busAlert.id)
        
        region1.notifyOnEntry = true
        region1.notifyOnExit = false
        
        let region2 = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: busStopLocal.gpslati, longitude: busStopLocal.gpslong),
            radius: 30.0, // 30m 반경
            identifier: busAlert.id + "_region2") // region2에 고유한 식별자를 추가)
        
        region2.notifyOnEntry = true
        region2.notifyOnExit = false
    
        // `region2`의 식별자를 `activeAlarms`에 추가
        activeAlarms.insert(region2)
        
        // 현재 위치 확인
            if let currentLocation = manager.location?.coordinate {
                if region1.contains(currentLocation) {
                    print("이미 70미터 반경 안에 있습니다: \(region1.identifier)")
                    if let busAlert = getBusAlert(for: region1.identifier) {
                        startNotifications(for: busAlert)
                    }
                } else {
                    print("현재 위치는 70미터 반경 밖에 있습니다: \(region1.identifier)")
                }
            } else {
                print("현재 위치를 가져올 수 없습니다. 위치 업데이트를 시작합니다.")
//                manager.startUpdatingLocation()
            }
        
        // 새로운 region 모니터링 시작
        manager.startMonitoring(for: region1)
        print("(70미터 반경 확인합니다)Started monitoring region1 for \(busAlert.alertLabel ?? "")")
    }
    
    // 버스 알람 해제
    func unregisterBusAlert(_ busAlert: BusAlert) {
        stopNotifications(for: busAlert)
        activeBusAlerts.removeValue(forKey: busAlert.id)
        activeAlarms.removeAll()
        
        // Region 모니터링 중지
        manager.monitoredRegions.forEach { region in
            if region.identifier == busAlert.id {
                manager.stopMonitoring(for: region)
            }
        }
        manager.stopUpdatingLocation()
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
    /// 위치 권한 상태를 확인하고 필요한 요청을 수행하는 함수
    public func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            requestWhenInUsePermission()
        case .authorizedWhenInUse:
            requestAlwaysPermission()
        case .authorizedAlways:
            print("Always 권한 이미 허용됨.")
        case .restricted:
            errorMessage = "위치 서비스 접근이 제한되어 있습니다."
        case .denied:
            errorMessage = "위치 서비스 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
        @unknown default:
            print("알 수 없는 권한 상태")
        }
    }

    /// "앱을 사용하는 동안" 권한 요청
    public func requestWhenInUsePermission() {
        print("WhenInUse 권한 요청 중...")
        manager.requestWhenInUseAuthorization()
    }

    /// "항상 허용" 권한 요청
    public func requestAlwaysPermission() {
        print("Always 권한 요청 중...")
        manager.requestAlwaysAuthorization()
    }

    /// 권한 상태가 변경될 때 호출
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print("권한 상태 변경됨: \(status.rawValue)")
        
        // 변경된 상태에 따라 필요한 동작 수행
        checkLocationAuthorization()
    }
    
    private func getBusAlert(for identifier: String) -> BusAlert? {
        // "_region2" 접미사를 제거한 식별자로 검색
        let cleanIdentifier = identifier.replacingOccurrences(of: "_region2", with: "")
        return activeBusAlerts[cleanIdentifier]
    }
    
    // 모든 모니터링 중지
    func stopAllMonitoring() {
        activeBusAlerts.forEach { (_, busAlert) in
            unregisterBusAlert(busAlert)
        }
        activeBusAlerts.removeAll()
        activeNotifications.removeAll()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            // 무음 모드에서도 재생되도록 설정
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }
    
    private func loadAudioFile() {
        if let path = Bundle.main.path(forResource: "AlarmSound", ofType: "mp3") {
            // forResourece : 안에 오디오 파일 이름 넣기
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                // 오디오 파일 미리 로드
                player?.prepareToPlay()
                // 볼륨을 최대로 설정
                player?.volume = 0.8
                print("오디오 파일 로드 성공")
            } catch {
                print("오디오 파일 로드 실패: \(error)")
                print("파일 경로: \(path)")
            }
        } else {
            print("AlarmSound.mp3 파일이 없습니다.")
        }
    }
    
    func playAudio() {
        // 현재 시스템 볼륨 저장
        let currentVolume = AVAudioSession.sharedInstance().outputVolume
        originalVolume = AVAudioSession.sharedInstance().outputVolume
        
        // 볼륨이 낮으면 최대로 설정
        if originalVolume < 1 {
            setSystemVolume(0.6)
        }
        
        // 여러 번 반복 재생 설정
        player?.numberOfLoops = 5  // 5번 반복
        player?.play()
        
        // 20초 후에 원래 볼륨으로 복구
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            self?.stopAudio()
        }
    }
    
    func stopAudio() {
        player?.stop()
        setSystemVolume(originalVolume)
    }
    
    private func setSystemVolume(_ volume: Float) {
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.async {
                slider.value = volume
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    // Region 진입 시 호출되는 delegate 메서드
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("(70미터 반경 안에 들어왔음)Entered region: \(region.identifier)")
        if let busAlert = getBusAlert(for: region.identifier) {
//            startNotifications(for: busAlert)
            manager.startUpdatingLocation()
            print("1초마다 업데이트 시작")
            print("!!!!!!!!!!!!!!!Location updated 시작한다!!!!!!!!!!!!!!!")
        }
    }
    
    // 위치 업데이트 때 마다 호출되는 delegate 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 유효한 위치 데이터인지 확인
        if location.horizontalAccuracy > 0 {
            self.location = location
            self.region = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            print("!!!!!!!!!!!!!!!Location updated!!!!!!!!!!!!!!!")
            print(activeAlarms)
            
            // 등록된 모든 region에 대해 현재 위치 확인
            for monitoredRegion in activeAlarms {
                if monitoredRegion.contains(location.coordinate) {
                    print(monitoredRegion.center)
                    print("현재 위치가 \(monitoredRegion.identifier) 영역 안에 있습니다.")
                    // 진입 이벤트 처리
                    if let busAlert = getBusAlert(for: monitoredRegion.identifier) {
                            print("BusAlert 가져오기 성공: \(busAlert.alertLabel ?? "")")
                            startNotifications(for: busAlert)
                        } else {
                            print("BusAlert를 찾을 수 없습니다: \(monitoredRegion.identifier)")
                        }
                } else {
                    print("현재 위치가 \(monitoredRegion.identifier) 영역 밖에 있습니다.")
                }
            }
        }
    }
    
    /// 위치 갱신 실패 시 오류 메시지를 설정하고 콘솔에 출력
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed with error: \(error.localizedDescription)")
    }
}

