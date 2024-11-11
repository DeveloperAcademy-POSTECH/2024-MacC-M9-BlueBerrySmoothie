//
//  MainView.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query var busAlerts: [BusAlert] // 알람 데이터를 바인딩
    @Query var busStopLocal: [BusStopLocal]
    @State private var selectedAlert: BusAlert? // State to store the selected BusAlert
    @State private var isUsingAlertActive: Bool = false // Controls navigation to UsingAlertView
    
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
        NavigationView {
            VStack{
                alertListView()
                
                Spacer()
                
                //데이지데이지데이지데이지데이지데이지
                let alertBusStopLocal = busStopLocal.filter{$0.nodeid == selectedAlert?.alertBusStopID}.first
                let arrivalBusStopLocal = busStopLocal.filter{$0.nodeid == selectedAlert?.arrivalBusStopID}.first
                
//                NavigationLink(
//                    destination: selectedAlert.flatMap { alert in
//                        if let alertBusStopLocal = alertBusStopLocal,
//                           let arrivalBusStopLocal = arrivalBusStopLocal {
//                            return UsingAlertView(busAlert: alert, alertBusStopLocal: alertBusStopLocal, arrivalBusStopLocal: arrivalBusStopLocal)
//                        } else {
//                            return nil
//                        }
//                    },
//                    isActive: $isUsingAlertActive
//                ) {
//                    EmptyView()
//                }

                
                // 시작하기 버튼
                Button(action: {
                    // 선택된 alert와 해당 busStop들을 안전하게 언래핑합니다.
                    guard let selectedAlert = selectedAlert,
                          let alertBusStopLocal = alertBusStopLocal,
                          let arrivalBusStopLocal = arrivalBusStopLocal else {
                        print("선택된 알람 또는 버스 정류장이 설정되지 않았습니다.")
                        return
                    }
                    
                    isUsingAlertActive = true // Activate navigation
                    print(selectedAlert.alertLabel)
                    notificationManager.requestAuthorization()
                    notificationManager.scheduleTestNotification(for: selectedAlert)
                    notificationManager.requestLocationNotification(for: selectedAlert, for: alertBusStopLocal)
                    notificationManager.requestLocationNotification(for: selectedAlert, for: arrivalBusStopLocal)
                }, label: {
                    ActionButton()
                })
                
            }
            .padding(20)
            .navigationTitle("버스 알람: 핫!챠")
            .toolbar {
                ToolbarItem {
                    NavigationLink("추가") {
                        AlertSettingMain(isEditing: false)
                    }
                  .font(.medium16)
                        .foregroundColor(Color.brand)
                }
            }
            .background(Color.white)
        }
        .tint(Color.brand)
        .onAppear(){
            print(busAlerts)
        }
    }
    
    private func alertListView() -> some View {
        ScrollView {
            ForEach(busAlerts, id: \.id) { alert in
//                SavedBus(busAlert: alert, isSelected: selectedAlert?.id == alert.id)
                SavedBus(busAlert: alert, isSelected: selectedAlert?.id == alert.id, onDelete: {
                                    deleteBusAlert(alert) // 삭제 동작 전달
                                })
                    .onTapGesture {
                        selectedAlert = alert // Set the selected alert 
                        print(selectedAlert?.alertLabel)

                    }
                    .padding(.bottom, 8)
            }
        }
    }
}


