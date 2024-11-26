//
//  SavedBus.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI

struct SavedBus: View {
//    @State private var busAlert: BusAlert // 수정 가능하게 변경
    let busStopLocals: [BusStopLocal]
    let busAlert: BusAlert?
    var isSelected: Bool = false
    var onDelete: () -> Void // 삭제 핸들러
    var isEmptyAlert: Bool
    
    let notificationManager = NotificationManager.instance
    @StateObject private var locationManager = LocationManager.shared
        
    @State private var alertShowing = false
    @State private var isEditing: Bool = false
    @State private var isPinned: Bool = false
    @State private var isUsingAlertActive: Bool = false
    @State private var alertStop: BusStopLocal?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.gray7.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)
                .cornerRadius(12)
            Rectangle()
                .foregroundColor(Color.clear)
                .cornerRadius(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray5, lineWidth: 1)
                }
            VStack {

                HStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.lightbrand)
                            .cornerRadius(4)
                        Text(busAlert?.alertLabel ?? "알림")
                            .font(.title2)
//                            .font(.regular12)
                            .padding(4)
                            .foregroundColor(Color.brand)
                    }
                    .fixedSize(horizontal: true, vertical: true)
                    .padding(.top, 8)

                    Spacer()
                    
                    Menu {
                        Button(action: {
                            // 수정
                            isEditing = true
                        }, label: {
                            Label("수정", systemImage: "pencil")
                        })
                        
                        Button(action: {
                            // 상단 고정
                            busAlert?.isPinned.toggle()
                            isPinned = busAlert?.isPinned ?? false
                        }, label: {
                            Label(busAlert?.isPinned == true ? "상단 고정 해제" : "상단 고정", systemImage: "pin.fill")
                        })
                        
                        Button(action: {
                            // 삭제
                            alertShowing = true
                        }, label: {
                            Label("삭제", systemImage: "trash")
                                .foregroundStyle(.red)
                        })
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
//                            .font(.regular20)
                            .foregroundColor(Color.gray3)
                            .padding(.vertical, 20)
                    }
                    
                }

                VStack(spacing: 0) {
                    HStack {
                        Rectangle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.green)
                        Text(busAlert?.busNo ?? "버스번호없음")
//                            .font(.medium30)
                            .font(.caption1)
                        // 고정핀 위치
                        if busAlert?.isPinned == true {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.gray1)
                        }
                        Spacer()
                    }
                    HStack {
                        Text(busAlert?.arrivalBusStopNm ?? "도착정류장")
                            .font(.title3)
//                            .font(.medium20)
                        Spacer()
                    }
                }
                .foregroundColor(Color.black)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundColor(Color.brand)
                    Text("\(busAlert!.alertBusStop) 정류장 전 알람")
                        .font(.caption1)
                        .foregroundColor(Color.brand)
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 2, height: 12)
                        .background(Color.gray5)
                    
                    Text(findAlertBusStop(busAlert: busAlert!, busStops: busStopLocals)?.nodenm ?? "정류장명없음")
                
                    

                        .font(.caption1)
//                        .font(.regular12)
                        .foregroundColor(Color.gray2)
                    Text("\(busAlert!.alertBusStop) 정류장 전")
                        .font(.caption1)
//                        .font(.regular14)
                        .foregroundColor(Color.gray2)

                    Spacer()
                }
                .padding(.bottom, -4)
                Spacer()
                
                NavigationLink(destination: Group {
                    if let busAlert = busAlert,
                    let stop = alertStop {
                        UsingAlertView(
                            busAlert: busAlert,
                            alertStop: .constant(stop)
                        )
                    }
                }, isActive: $isUsingAlertActive) {
                    HStack {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .background(isEmptyAlert ? Color.gray4 : Color.white)
                                .cornerRadius(30)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.gray5, lineWidth: 1)
                                }
                            HStack {
                                Image(systemName: "play.fill")
//                                    .font(.regular14)
                                    .foregroundColor(.gray1)
                                Text("시작하기")
//                                    .font(.regular14)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            
                        }
                        .fixedSize(horizontal: true, vertical: true)
                        .onTapGesture {
                            startAlert()
                        }
                        Spacer()
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 20)
            .padding(.bottom)
            
        }
        .fixedSize(horizontal: false, vertical: true)
        .sheet(isPresented: $isEditing) {
            NavigationView{
                AlertSettingMain(busAlert: busAlert, isEditing: true) // `busAlert`을 `AlertSettingMain`으로 전달
            }
        }
        .alert("알람 삭제", isPresented: $alertShowing) {
            Button("삭제", role: .destructive) {
                onDelete()
            }
            Button("취소", role: .cancel){}
        } message: {
            Text("알람을 삭제하시겠습니까?")
        }
    }
    
    // MARK: - 알람 시작 함수
    private func startAlert() {
        guard let busAlert = busAlert,
              let foundStop = findAlertBusStop(busAlert: busAlert, busStops: busStopLocals) else {
            print("알람 또는 버스 정류장 정보가 없습니다.")
            return
        }
        
        // 알람 정류장 설정
        alertStop = foundStop
        
        // 라이브 액티비티 시작
//        LiveActivityManager.shared.startLiveActivity()
        
        // 알림 설정 및 위치 모니터링 시작
        notificationManager.notificationReceived = false
        notificationManager.requestAuthorization()
        locationManager.registerBusAlert(busAlert, busStopLocal: foundStop)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isUsingAlertActive = true
        }
    }
}

