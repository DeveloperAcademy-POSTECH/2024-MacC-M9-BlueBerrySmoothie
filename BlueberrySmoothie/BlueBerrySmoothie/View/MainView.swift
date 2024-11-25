

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
                Color.lightbrand
                    .ignoresSafeArea()
                VStack {
                    alertListView()
                    Spacer()
                  
                    NavigationLink(
                        destination: Group {
                            if let selectedAlert = selectedAlert {
                                UsingAlertView(
                                    busAlert: selectedAlert,
                                    alertStop: $alertStop
                                )
                            }
                        },
                        isActive: $isUsingAlertActive
                    ) {
                        EmptyView()
                    }
                   
                    // 시작 버튼
                    startButton(arrivalBusStopLocal: alertStop)
                }
                .padding(20)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSetting = true
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
                    //오류
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("버스 알람: 햣챠")
                            .font(.title3)
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
                ScrollView(showsIndicators: false) {
                    ForEach(busAlerts, id: \.self) { alert in
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
    
    /// 시작하기 버튼
    private func startButton(arrivalBusStopLocal: BusStopLocal?) -> some View {
        Button(action: {
            guard let selectedAlert = selectedAlert,
                  let alertBusStopLocal = alertStop else {
                print("선택된 알람 또는 버스 정류장이 설정되지 않았습니다.")
                return
            }
            
            // 라이브 액티비티 시작
            LiveActivityManager.shared.startLiveActivity(stationName: selectedAlert.arrivalBusStopNm, initialProgress: 3, currentStop: selectedAlert.arrivalBusStopNm, stopsRemaining: 5)
            
            
            // 알림 설정
            isUsingAlertActive = true // Activate navigation
            notificationManager.notificationReceived = false
            notificationManager.requestAuthorization()
            locationManager.registerBusAlert(selectedAlert, busStopLocal: alertBusStopLocal)
        }, label: {
            // 시작하기 버튼 UI
            startButtonUI(isEmptyAlert: selectedAlert == nil)
        })
        .disabled(selectedAlert == nil)
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
