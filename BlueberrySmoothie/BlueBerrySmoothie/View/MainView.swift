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
    @Query var busAlerts: [BusAlert]
    @Query var busStopLocal: [BusStopLocal]
    @State private var selectedAlert: BusAlert? // State to store the selected BusAlert
    @State private var isUsingAlertActive: Bool = false // Controls navigation to UsingAlertView
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    alertListView()
                    
                    Spacer()
                    
                    NavigationLink {
                        //여기 수정하기... ㅠㅠ busAlert에 selectedAlert 넣는 방법!
                        selectedAlert.map { UsingAlertView(busStops: busStopLocal, busAlert: $0)}
                    } label: {
                        ActionButton()
                    }.onTapGesture {
                        isUsingAlertActive = true // Activate navigation
                        print(selectedAlert?.alertLabel)
                    }
                    
                    //                Button(action: {
                    //                    NavigationLink(ActionButton()){
                    //                        UsingAlertView(busStops: busStopLocal, busAlert: <#T##BusAlert#>, isAlertEnabled: <#T##Bool#>)
                    //                    }
                    //                    guard selectedAlert != nil else {
                    //                        print("No alert selected")
                    //                        return
                    //                    }
                    
                    //                }, label: {
                    //                    ActionButton()
                    //                })
                    //                .disabled(selectedAlert == nil) // Disable button if no alert is selected
                }
                .padding(20)
                .navigationTitle("버스 알람: 핫!챠")
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
                                AlertSettingMain(showSetting: $showSetting)
                            }
                        }
                    }
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
                SavedBus(busAlert: alert, isSelected: selectedAlert?.id == alert.id)
                    .onTapGesture {
                        selectedAlert = alert // Set the selected alert
                    }
                    .padding(.bottom, 8)
            }
        }
    }
}


