//
//  MainView.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @State private var showSetting: Bool = false
    @Query var busAlerts: [BusAlert] // 알람 데이터를 바인딩
    @Query var busStopLocal: [BusStopLocal]
    @State private var selectedAlert: BusAlert? // State to store the selected BusAlert
    @State private var mainToSetting: BusAlert? = nil
    @State private var isUsingAlertActive: Bool = false // Controls navigation to UsingAlertView
    @State private var isEmptyAlert: Bool = true
    @State private var isSelected: Bool = false
    @State private var isEditing: Bool = false
    
    @Environment(\.modelContext) private var context // SwiftData의 ModelContext 가져오기
    let notificationManager = NotificationManager.instance
    
    @State private var alertStop: BusStopLocal? // alertStop을 상태로 관리
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    private func deleteBusAlert(_ busAlert: BusAlert) {
        // SwiftData의 ModelContext를 통해 객체 삭제
        context.delete(busAlert)
        // SwiftData는 별도의 save() 없이 자동으로 변경 사항을 처리합니다.
        print("Bus alert \(busAlert.alertLabel) deleted.")
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                Color.lightbrand
                    .ignoresSafeArea()
                VStack {
                    alertListView()
                    
                    Spacer()
                    
                    let arrivalBusStopLocal = busStopLocal.filter { $0.nodeid == selectedAlert?.arrivalBusStopID }.first
                    
                    
                    NavigationLink(
                        destination: Group {
                            if let selectedAlert = selectedAlert,
                               let arrivalBusStopLocal = arrivalBusStopLocal {
                                UsingAlertView(
                                    busAlert: selectedAlert,
                                    arrivalBusStopLocal: arrivalBusStopLocal,
                                    alertStop: $alertStop
                                )
                            }
                        },
                        isActive: $isUsingAlertActive
                    ) {
                        EmptyView()
                    }
                    //                    NavigationLink(
                    //                        destination: selectedAlert.flatMap { alert in
                    //                            if /*let alertBusStopLocal = alertBusStopLocal,*/
                    //                               let arrivalBusStopLocal = arrivalBusStopLocal {
                    //                                return UsingAlertView(busAlert: alert, /*alertBusStopLocal: alertBusStopLocal,*/ arrivalBusStopLocal: arrivalBusStopLocal, alertStop: $alertStop)
                    //                            } else {
                    //                                return nil
                    //                            }
                    //                        },
                    //                        isActive: $isUsingAlertActive
                    //                    ) {
                    //                        EmptyView()
                    //                    }
                    
                    
                    //TODO: 이 버튼도 StartButton으로 분리
                    Button(action: {
                        guard let selectedAlert = selectedAlert,
                              let alertBusStopLocal = alertStop,
                              let arrivalBusStopLocal = arrivalBusStopLocal else {
                            print("선택된 알람 또는 버스 정류장이 설정되지 않았습니다.")
                            return
                        }
                        isUsingAlertActive = true // Activate navigation
                        print(selectedAlert.alertLabel)
                        notificationManager.requestAuthorization()
                        //                        notificationManager.scheduleTestNotification(for: selectedAlert)
                        notificationManager.requestLocationNotification(for: selectedAlert, for: alertBusStopLocal)
                        notificationManager.requestLocationNotification(for: selectedAlert, for: arrivalBusStopLocal)
                    }, label: {
                        // 시작하기 버튼
                        // TODO: StartButtonUI로 이름 수정
                        ActionButton(isEmptyAlert: isEmptyAlert)
                    })
                    .disabled(isEmptyAlert)
                }
                .padding(20)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { // 위치를 명확히 지정
                        Button(action: {
                            showSetting = true // sheet 표시 상태를 true로 설정
                        }) {
                            Text("추가")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.brand)
                        }
                        .sheet(isPresented: $showSetting) {
                            NavigationView {
                                AlertSettingMain(/*isEditing: $isEditing*/)
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) { // 위치를 명확히 지정
                        Text("버스 알람: 햣챠")
                            .font(.mediumbold24)
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
    
    private func alertListView() -> some View {
        ZStack {
            if busAlerts.isEmpty {
                VStack {
                    Text("도착 정류장을 추가해주세요")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            } else {
                ScrollView(showsIndicators: false)  {
                    ForEach (busAlerts, id: \.self) { alert in
                        // 저장된 알람에 대한 각각의 노드
                        SavedBus(busStopLocals: busStopLocal, busAlert: alert, isSelected: selectedAlert?.id == alert.id, onDelete: {
                            deleteBusAlert(alert) // 삭제 동작
                            if busAlerts.isEmpty {
                                isEmptyAlert = true
                            }
                        })
                        .onTapGesture {
                            selectedAlert = alert // 선택된 알람 설정
                            if let foundStop = findAlertBusStop(busAlert: alert, busStops: busStopLocal) {
                                alertStop = foundStop
                            }
                            if busAlerts.count != 0 {
                                isEmptyAlert = false
                            }
//                            print(selectedAlert?.alertLabel)
//                            print("foundStop: \(alertStop?.nodenm)")
//                            print(alert.alertLabel)
                            
                        }
                        .padding(2) // padding을 조금 추가하여 스트로크가 잘리는 것을 방지
                        .padding(.bottom, 1) // 아이템 간 간격 유지
                    }
                }
            }
        }
    }
}
