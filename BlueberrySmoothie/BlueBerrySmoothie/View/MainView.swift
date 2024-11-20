

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
    
    var body: some View {
        NavigationView {
            ZStack {
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
                    
                    // 시작 버튼
                    startButton(arrivalBusStopLocal: arrivalBusStopLocal)
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
                    ToolbarItem(placement: .navigationBarLeading) {
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
                ScrollView(showsIndicators: false) {
                    ForEach(busAlerts, id: \.self) { alert in
                        SavedBus(busStopLocals: busStopLocal, busAlert: alert, isSelected: selectedAlert?.id == alert.id, onDelete: {
                            deleteBusAlert(alert)
                            if busAlerts.isEmpty {
                                isEmptyAlert = true
                            }
                        })
                        .onTapGesture {
                            selectedAlert = alert
                            if let foundStop = findAlertBusStop(busAlert: alert, busStops: busStopLocal) {
                                alertStop = foundStop
                            }
                            if busAlerts.count != 0 {
                                isEmptyAlert = false
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
                  let alertBusStopLocal = alertStop,
                  let arrivalBusStopLocal = arrivalBusStopLocal else {
                print("선택된 알람 또는 버스 정류장이 설정되지 않았습니다.")
                return
            }
            
            // 라이브 액티비티 시작
            LiveActivityManager.shared.startLiveActivity()
            
            // 알림 설정
            isUsingAlertActive = true
            notificationManager.requestAuthorization()
            notificationManager.requestLocationNotification(for: selectedAlert, for: alertBusStopLocal)
            notificationManager.requestLocationNotification(for: selectedAlert, for: arrivalBusStopLocal)
        }, label: {
            // 시작하기 버튼 UI
            startButtonUI(isEmptyAlert: isEmptyAlert)
        })
        .disabled(isEmptyAlert)
    }
    
    private func deleteBusAlert(_ busAlert: BusAlert) {
        context.delete(busAlert)
        print("Bus alert \(busAlert.alertLabel) deleted.")
    }
}
