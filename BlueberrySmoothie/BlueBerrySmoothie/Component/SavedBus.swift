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
    
    let notificationManager = NotificationManager.instance
    @StateObject private var locationManager = LocationManager.shared
    
    @State private var alertShowing = false
    @State private var isEditing: Bool = false
    @State private var isPinned: Bool = false
    @State private var isUsingAlertActive: Bool = false
    @State private var alertStop: BusStopLocal?
    
    var body: some View {

            VStack {
                //알람 이름 , 메뉴버튼
                HStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.lightbrand)
                            .cornerRadius(4)
                        Text(busAlert?.alertLabel ?? "알림")
                            .font(.caption2)
                            .padding(4)
                            .foregroundColor(Color.brand)
                    }
                    .fixedSize(horizontal: true, vertical: true)
                    .padding(.top, 9)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            // 수정
                            isEditing = true
                        }, label: {
                            Label("수정", image: "pencil")
                        })
                        
                        Button(action: {
                            // 상단 고정
                            busAlert?.isPinned.toggle()
                            isPinned = busAlert?.isPinned ?? false
                        }, label: {
                            Label(busAlert?.isPinned == true ? "상단 고정 해제" : "상단 고정", image: "pin")
                        })
                        
                        Button(role: .destructive, action: {
                            // 삭제
                            alertShowing = true
                        }, label: {
                            Label("삭제", image: "trash")
                        })
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(Color.gray3Dgray6)
                    }
                }
                .padding(.top, 7)
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
                
                // 버스 번호, 정류장
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.fill")
                            .frame(width: 12, height: 12)
                            .foregroundStyle(busColor(for: busAlert?.routetp ?? ""))
                        Text(busAlert?.busNo ?? "버스번호없음")
                            .font(.title1)
                            .foregroundStyle(.blackdgray71)
                        // 고정핀 위치
                        if busAlert?.isPinned == true {
                            Image("pin")
                                .foregroundColor(.gray1Dgray6)
                                .font(.title2)
                        }
                        Spacer()
                    }
                    HStack {
                        Text(busAlert?.arrivalBusStopNm ?? "도착정류장")
                            .font(.title2)
                            .foregroundStyle(.blackdgray71)
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundColor(Color.gray2)
                    Text("\(busAlert!.alertBusStop) 정류장 전")
                        .font(.caption1)
                        .foregroundColor(Color.gray2)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                Spacer()
                
                HStack {
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
                                    .background(Color.white)
                                    .cornerRadius(30)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.gray5, lineWidth: 1)
                                    }
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.caption1)
                                        .foregroundColor(.grayfix1)
                                    Text("시작하기")
                                        .font(.caption1)
                                        .foregroundColor(.black)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                
                            }
                            .fixedSize(horizontal: true, vertical: true)
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        startAlert()
                    })
                    .padding(.bottom, 16)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
            }
            .background{
                Image(busAlertBackground(for: busAlert?.routetp ?? ""))
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // 크기를 최대한 늘림
            }
            .padding(.top, 8)
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

