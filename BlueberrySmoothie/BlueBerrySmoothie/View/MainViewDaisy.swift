//
//  MainView.swift
//  Macro_Study_SwiftData
//
//  Created by 원주연 on 10/29/24.
//

import SwiftUI
import SwiftData

struct MainViewDaisy: View {
    
    @Environment(\.modelContext) private var modelContext
    // 전체 alert 데이터 반환
    @Query var alerts: [Alert]
    //    @StateObject private var locationManager = LocationManager()
    
    
    var body: some View {
        NavigationView {
            VStack{
                HStack {
                    ListAlertView(alerts: alerts)
                    
                }
                .navigationTitle("알람 선택")
                .toolbar {
                    ToolbarItem {
                        NavigationLink("추가") {
                            InputViewDaisy()
                        }
                    }
                }
            }
        }
    }
}

struct ListAlertView: View {
    var alerts: [Alert]
    @Environment(\.modelContext) private var modelContext
    
    // 두 열로 구성된 그리드 레이아웃
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    func deleteAlert(_ alert: Alert) {
        modelContext.delete(alert)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(alerts, id: \.alertID) { alert in
                    AlertListCell(alert: alert, onDelete: { deleteAlert(alert)})
                }
            }
        }
    }
}

struct AlertListCell: View {
    let alert: Alert
    var onDelete: () -> Void // 삭제 핸들러
    @State private var isEditing = false
    @State private var alertShowing = false
    @State private var isUsingAlertViewActive = false // UsingAlertView로의 이동 상태
    let notificationManager = NotificationManager.instance
    //    let notificationManager = NotificationManager()
    @StateObject private var locationManager = LocationManager()
    
    
    var body: some View {
        VStack {
            Text("버스 번호: \(alert.busNumber)")
            Text("정류장 이름: \(alert.busStopName)")
            Text("\(alert.alertStopsBefore)정류장 전에 알람")
            
            NavigationLink(
                destination: UsingAlertViewDaisy(alert: alert),
                isActive: $isUsingAlertViewActive
            ) {
                EmptyView()
            }
            
            // 활성화하기 버튼
            Button(action: {
                print("활성화하기")
                alert.isActivating = true
                notificationManager.requestAuthorization()
//                locationManager.manager.startUpdatingLocation()
                locationManager.startLocationUpdates()
                notificationManager.scheduleTestNotification(for: alert)
                //                notificationManager.requestLocationNotification()
                
                isUsingAlertViewActive = true
            }, label: {
                Text("활성화하기")
            })
            .padding(.top, 8)
            
            
            // 수정하기 버튼
            Button(action: {
                isEditing = true
            }, label: {
                Text("수정하기")
            })
            .padding(.top, 8)
            .sheet(isPresented: $isEditing) {
                InputViewDaisy(alert: alert)
            }
            
            // 삭제하기 버튼 (+alert)
            Button(action: {
                alertShowing = true
            }, label: {
                Text("삭제하기")
                    .foregroundStyle(.red)
            })
            .padding(.top, 4)
            .alert("알람 삭제", isPresented: $alertShowing) {
                Button("삭제", role: .destructive) {
                    onDelete()
                }
                Button("취소", role: .cancel){}
            } message: {
                Text("알람을 삭제하시겠습니까?")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    MainViewDaisy()
}
