//
//  AlarmTestView.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/18/24.
//

import SwiftUI
import AVFoundation
import UserNotifications
import MediaPlayer

class AudioManager: ObservableObject {
    private var player: AVAudioPlayer?
    private var originalVolume: Float = 0.0
    private let volumeView = MPVolumeView()
    
    init() {
        setupAudioSession()
        loadAudioFile()
        // 볼륨 뷰를 화면 밖에 위치시킴 (시스템 볼륨 UI 숨기기)
        volumeView.frame = CGRect(x: -100, y: -100, width: 0, height: 0)
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            // 무음 모드에서도 재생되도록 설정
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }
    
    private func loadAudioFile() {
        if let path = Bundle.main.path(forResource: "Blue Ribbons - TrackTribe", ofType: "mp3") {
            // forResourece : 안에 오디오 파일 이름 넣기
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                // 오디오 파일 미리 로드
                player?.prepareToPlay()
                // 볼륨을 최대로 설정
                player?.volume = 0.3
            } catch {
                print("오디오 파일 로드 실패: \(error)")
            }
        }
    }
    
    func playAudio() {
        // 현재 시스템 볼륨 저장
        originalVolume = AVAudioSession.sharedInstance().outputVolume
        
        // 볼륨이 낮으면 최대로 설정
        if originalVolume < 0.5 {
            maximizeVolume()
        }
        
        // 여러 번 반복 재생 설정
        player?.numberOfLoops = 5  // 5번 반복
        player?.play()
        
        // 20초 후에 원래 볼륨으로 복구
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            self?.restoreVolume()
        }
    }
    
    func stopAudio() {
        player?.stop()
        restoreVolume()
    }
    
    private func maximizeVolume() {
        // MPVolumeView를 통해 시스템 볼륨을 최대로 설정
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                slider.value = 0.3  // 최대 볼륨
            }
        }
    }
    
    private func restoreVolume() {
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            slider.value = originalVolume
        }
    }
}

class TimerManager: ObservableObject {
    @Published var isTimerRunning = false
    @Published var remainingSeconds = 10
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var audioManager: AudioManager
    
    init(audioManager: AudioManager) {
        self.audioManager = audioManager
        setupNotifications()
    }
    
    func startTimer() {
        isTimerRunning = true
        remainingSeconds = 10
        
        // 백그라운드 작업 시작
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        // 로컬 알림 설정
        scheduleLocalNotification()
        
        // 타이머 시작
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                if self.remainingSeconds == 0 {
                    self.timerCompleted()
                }
            }
        }
    }
    
    private func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "타이머 완료"
        content.body = "알람이 울립니다!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func timerCompleted() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        audioManager.playAudio()
        endBackgroundTask()
    }
    
    func stopAlarm() {
        audioManager.stopAudio()
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("알림 권한 승인 여부: \(granted)")
        }
    }
}

struct AlarmTestView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var timerManager: TimerManager
    
    init() {
        let audioManager = AudioManager()
        _timerManager = StateObject(wrappedValue: TimerManager(audioManager: audioManager))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(timerManager.remainingSeconds)초")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(timerManager.isTimerRunning ? .blue : .primary)
            
            Button(action: {
                if !timerManager.isTimerRunning {
                    timerManager.startTimer()
                }
            }) {
                Text(timerManager.isTimerRunning ? "타이머 실행 중..." : "10초 타이머 시작")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(timerManager.isTimerRunning ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(timerManager.isTimerRunning)
            
            if timerManager.remainingSeconds == 0 {
                Button(action: {
                    timerManager.stopAlarm()
                }) {
                    Text("알람 끄기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

#Preview {
    AlarmTestView()
}

