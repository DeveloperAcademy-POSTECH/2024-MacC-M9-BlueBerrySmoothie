

import SwiftUI
import SwiftData

struct MainView: View {
    @State private var showSetting: Bool = false
    @Query var busAlerts: [BusAlert] // 알람 데이터를 바인딩
    @Query var busStopLocal: [BusStopLocal]
    @State private var selectedAlert: BusAlert? // State to store the selected BusAlert
    @State private var mainToSetting: BusAlert? = nil
    @State private var isUsingAlertActive: Bool = false // Controls navigation to UsingAlertView
    @State private var isSelected: Bool = false
    @State private var isEditing: Bool = false
    
    @Environment(\.modelContext) private var context // SwiftData의 ModelContext 가져오기
    let notificationManager = NotificationManager.instance
    @StateObject private var locationManager = LocationManager.shared
    
    @State private var alertStop: BusStopLocal? // alertStop을 상태로 관리
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.whiteDBlack
                    .ignoresSafeArea()
                VStack {
                    alertListView()
                    
                }
                .padding(.horizontal, 20)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                showSetting = true
                            }) {
                                Image("mark")
//                                    .font(.regular20)
                                    .foregroundColor(Color.gray1)
                            }
                            .sheet(isPresented: $showSetting) {
                                NavigationView {
                                    CitySettingView()// SelectCityMainView 로 바꿔야 함
                                }
                            }
                            
                            NavigationLink(destination: AlertSettingMain()){
                                Image("plus")
//                                    .font(.regular20)
                                    .foregroundColor(Color.gray1)
                            }
                        }
                    }
                    //오류
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("햣챠")
                            .font(.title3)
                            .foregroundStyle(.brand)
                    }
                }
                .background(.clear)
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
                ScrollView(showsIndicators: false) {
                    // 고정된 알림들을 먼저 표시
                    ForEach(busAlerts.filter { $0.isPinned }, id: \.self) { alert in
                        SavedBus(busStopLocals: busStopLocal, busAlert: alert, isSelected: selectedAlert?.id == alert.id, onDelete: {
                            deleteBusAlert(alert) // 삭제 동작
                        })
                        .onTapGesture {
                            selectedAlert = alert
                            if let foundStop = findAlertBusStop(busAlert: alert, busStops: busStopLocal) {
                                alertStop = foundStop
                            }
                        }
                        .padding(2)
                        .padding(.bottom, 1)
                    }
                    
                    ForEach(busAlerts.filter { !$0.isPinned }, id: \.self) { alert in
                        SavedBus(busStopLocals: busStopLocal, busAlert: alert, isSelected: selectedAlert?.id == alert.id, onDelete: {
                            deleteBusAlert(alert) // 삭제 동작
                        })
                        .onTapGesture {
                            selectedAlert = alert
                            if let foundStop = findAlertBusStop(busAlert: alert, busStops: busStopLocal) {
                                alertStop = foundStop
                            }
                        }
                        .padding(2)
                        .padding(.bottom, 1)
                    }
                }
            }
        }
    }
    

    private func deleteBusAlert(_ busAlert: BusAlert) {
        context.delete(busAlert)
        // 선택된 알람이 삭제된 경우 nil로 설정
        if selectedAlert?.id == busAlert.id {
            selectedAlert = nil
        }
        // SwiftData는 별도의 save() 없이 자동으로 변경 사항을 처리합니다.
        print("Bus alert \(busAlert.alertLabel) deleted.")
    }
}
