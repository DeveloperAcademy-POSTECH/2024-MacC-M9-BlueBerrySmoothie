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
    @State private var isUsingAlertActive: Bool = false // Controls navigation to UsingAlertView
    @State private var isEmptyAlert: Bool = true
    
    @Environment(\.modelContext) private var context // SwiftData의 ModelContext 가져오기
    let notificationManager = NotificationManager.instance
    
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
        NavigationStack {
            VStack {
                alertListView()
                
                Spacer()
                
                let alertBusStopLocal = busStopLocal.filter { $0.nodeid == selectedAlert?.alertBusStopID }.first
                let arrivalBusStopLocal = busStopLocal.filter { $0.nodeid == selectedAlert?.arrivalBusStopID }.first
                
                NavigationLink(
                    destination: selectedAlert.flatMap { alert in
                        if let alertBusStopLocal = alertBusStopLocal,
                           let arrivalBusStopLocal = arrivalBusStopLocal {
                            return UsingAlertView(busAlert: alert, alertBusStopLocal: alertBusStopLocal, arrivalBusStopLocal: arrivalBusStopLocal)
                        } else {
                            return nil
                        }
                    },
                    isActive: $isUsingAlertActive
                ) {
                    EmptyView()
                }
                
                Button(action: {
                    guard let selectedAlert = selectedAlert,
                          let alertBusStopLocal = alertBusStopLocal,
                          let arrivalBusStopLocal = arrivalBusStopLocal else {
                        print("선택된 알람 또는 버스 정류장이 설정되지 않았습니다.")
                        return
                    }
                    isUsingAlertActive = true // Activate navigation
                    print(selectedAlert.alertLabel)
                    notificationManager.requestAuthorization()
//                    notificationManager.scheduleTestNotification(for: selectedAlert)
                    notificationManager.requestLocationNotification(for: selectedAlert, for: alertBusStopLocal)
                    notificationManager.requestLocationNotification(for: selectedAlert, for: arrivalBusStopLocal)
                }, label: {
                    ActionButton(isEmptyAlert: $isEmptyAlert)
                })
            }
            .padding(20)
//            .background(Color.lightbrand)
            .navigationTitle("버스 알람: 핫챠")
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
                            AlertSettingMain()
                        }
                    }
                }
            }
            .onAppear(){
                print(busAlerts)
                if busAlerts.count != 0 {
                    isEmptyAlert = false
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
                ScrollView {
                    ForEach (busAlerts, id: \.id) { alert in
                        SavedBus(busAlert: alert, isSelected: selectedAlert?.id == alert.id, onDelete: {
                            deleteBusAlert(alert) // 삭제 동작
                        })
                        .onTapGesture {
                            selectedAlert = alert // 선택된 알람 설정
                            print(selectedAlert?.alertLabel)
                        }
                        .padding(2) // padding을 조금 추가하여 스트로크가 잘리는 것을 방지
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(selectedAlert?.id == alert.id ? Color.blue : Color.clear, lineWidth: 2) // 선택된 항목에 스트로크 추가
//                        )
                        .padding(.bottom, 1) // 아이템 간 간격 유지

                    }
                }
            }
        }
    }
}
