//
//  MainView.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query var busAlerts: [BusAlert]
    @Query var busStopLocal: [BusStopLocal]
    @State private var selectedAlert: BusAlert? // State to store the selected BusAlert
    @State private var isUsingAlertActive: Bool = false // Controls navigation to UsingAlertView
    
    
    var body: some View {
        NavigationView {
            VStack{
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
                ToolbarItem {
                    NavigationLink("추가") {
                        AlertSettingMain()
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255))
                }
            }
            
            // NavigationLink for UsingAlertView
//            NavigationLink(
//                destination: selectedAlert.map { UsingAlertView(busStops: busStopLocal, busAlert: $0) },
//                isActive: $isUsingAlertActive
//            ) {
//                EmptyView()
//            }
            
        }
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
        
        // Extracted destination for UsingAlertView
//        private func usingAlertDestination() -> some View {
//            UsingAlertView(busStops: busStopLocal, busAlert: selectedAlert!)
//        }
}


