import SwiftUI
import SwiftData
import Combine // Cancellable을 사용하기 위해 필요

struct UsingAlertView: View {
    @Query var busStops: [BusStopLocal]
    @StateObject private var currentBusViewModel = NowBusLocationViewModel() // ViewModel 연결
    @ObservedObject var notificationManager = NotificationManager.instance // NotificationManager 인스턴스 감지
    private let locationManager = LocationManager.shared // LocationManager 싱글톤 참조로 변경
    @Environment(\.dismiss) private var dismiss
    
    let busAlert: BusAlert // 관련된 알림 정보
    @State private var refreshTimerCancellable: Cancellable? // 타이머를 관리하기 위한 상태
    private let refreshInterval: TimeInterval = 10.0 // 새로고침 간격
    
    @State private var isAlertEnabled: Bool = false // 스위치 상태 관리
    @State private var isRefreshing: Bool = false // 새로고침 상태 관리
    @State private var lastRefreshTime: Date? = nil // 마지막 새로고침 시간
    @State private var showExitConfirmation = false
    @State private var positionIndex: Int = 1 // ScrollTo 변수
    @Binding var alertStop: BusStopLocal? // alertStop을 상태로 관리
    @State private var isScrollTriggered: Bool = false
    @State private var isFinishedLoading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    // x 종료 버튼
                    Button(action: {
                        self.showExitConfirmation.toggle();
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    })
                    Spacer()
                }
                .padding(.horizontal, 20)
                .alert("알람 종료", isPresented: $showExitConfirmation) {
                    Button("종료", role: .destructive) {
                        // 알림 취소
                        stopRefreshTimer() // 알람 종료 시 타이머도 중단
                        notificationManager.notificationReceived = false // 오버레이 닫기
                        locationManager.unregisterBusAlert(busAlert)
                        dismiss() // Dismiss the view if confirmed
                    }
                    Button("취소", role: .cancel){}
                } message: {
                    Text("알람을 종료하시겠습니까?")
                }
                
                BusAlertInfoView(busAlert: busAlert, alertStop: alertStop, isRefreshing: $isRefreshing) //여기에 BusAlertInfoView
                .background(Color.lightbrand)
                
                
                BusStopScrollView(
                    closestBus: $currentBusViewModel.closestBusLocation,
                    isRefreshing: $isRefreshing,
                    busStops: busStops,
                    busAlert: busAlert,
                    alertStop: alertStop,
                    viewModel: currentBusViewModel,
                    isScrollTriggered: $isScrollTriggered
                )
            }
            .background(Color.gray7)
            .navigationTitle(busAlert.alertLabel ?? "알람")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                currentBusViewModel.stopUpdating() // 뷰가 사라질 때 뷰모델에서 위치 업데이트 중단
                stopRefreshTimer() // 뷰 사라질 때 타이머 중단
            }
            RefreshButton(isRefreshing: isRefreshing, isScrollTriggered: $isScrollTriggered) {
                refreshData()
                isScrollTriggered = true
                print("refresh 버튼")
            }
            
            // 알람 로딩 오버레이 뷰
            if !isFinishedLoading {
                AlertLoadingView()
            }
            
            // 알람종료 오버레이 뷰
            if notificationManager.notificationReceived {
                AfterAlertView()
                    .edgesIgnoringSafeArea(.all) // 전체 화면에 적용
            }
        }
        .toolbar(.hidden)
        .onAppear {
            refreshData() // 초기 로드
            currentBusViewModel.startUpdating() // 뷰가 보일 때 뷰모델에서 위치 업데이트 시작
            startRefreshTimer() // 타이머 시작
        }
        .onChange(of: currentBusViewModel.closestBusLocation != nil) { isNotNil in
            if isNotNil {
                print("온체인지 감지")
                isFinishedLoading = true
                isScrollTriggered = true
                print(isFinishedLoading)
                print(isScrollTriggered)
            }
        }
        .onDisappear {
            currentBusViewModel.stopUpdating() // 뷰가 사라질 때 뷰모델에서 위치 업데이트 중단
            stopRefreshTimer() // 뷰 사라질 때 타이머 중단
            currentBusViewModel.closestBusLocation = nil
        }
    }
    
    struct BusAlertInfoView: View {
        let busAlert: BusAlert
        let alertStop: BusStopLocal? // 알림 정류장
        @Binding var isRefreshing: Bool
        
        var body: some View {
            VStack {
                VStack {
                    HStack {
                        Text("\(busAlert.busNo)")
                            .foregroundColor(Color.gray3)
                            .font(.title3)
                        Image(systemName: "suit.diamond.fill")
                            .font(.caption2)
                            .foregroundStyle(.midbrand)
                        Text("\(busAlert.arrivalBusStopNm)")
                            .foregroundColor(Color.gray2)
                            .font(.title3)
                        Spacer()
                    }
                    .padding(.bottom, 26)
                    
                    HStack {
                        Text("\(busAlert.alertBusStop)정류장 전 알림")
                            .foregroundStyle(.brand)
                            .font(.body2)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 26, height: 26)
                                .foregroundColor(Color.gray7)
                            Image(systemName: "bell.fill")
                                .frame(width: 14, height: 14)
                                .foregroundColor(Color.midbrand)
                        }
                        Text("\(alertStop!.nodenm)")
                            .foregroundColor(Color.black)
                            .font(.title)
                        Spacer()
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.top)
                .padding(.bottom, 28)
            }
        }
    }
    
    // BusStopList가 포함된 ScrollView
    struct BusStopScrollView: View {
        @Binding var closestBus: NowBusLocation? // 가장 가까운 버스
        @Binding var isRefreshing: Bool // 로딩 상태
        let busStops: [BusStopLocal] // 버스 정류장 목록
        let busAlert: BusAlert // 버스 알림 정보
        let alertStop: BusStopLocal? // 알림 정류장
        @ObservedObject var viewModel: NowBusLocationViewModel // ViewModel
        @Binding var isScrollTriggered: Bool // 스크롤하게 하는 트리거
        
        var body: some View {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 가장 가까운 버스가 감지 되었을 경우
                        if let closestBus = viewModel.closestBusLocation {
                            ForEach(busStops.filter { $0.routeid == busAlert.routeid }.sorted(by: { $0.nodeord < $1.nodeord }), id: \.id) { busStop in
                                
                                BusStopRow(
                                    busStop: busStop,
                                    isCurrentLocation: busStop.nodeid == closestBus.nodeid,
                                    arrivalBusStopID: busAlert.arrivalBusStopID,
                                    alertStop: alertStop
                                )
                            }
                        } else if isRefreshing {
                            // 로딩 중일 때 로딩 인디케이터 표시
                            ProgressView("가장 가까운 버스 위치를 찾고 있습니다...")
                                .foregroundColor(Color.black)
                                .font(.caption1)
                        } else {
                            Text("가장 가까운 버스 위치를 찾고 있습니다...")
                                .foregroundColor(Color.black)
                                .font(.caption1)
                        }
                        Spacer()
                    }
                    .background(.clear)
                }
                // 해당 버스 노드 위치로 스크롤하는 에니메이션
                .onChange(of: isScrollTriggered) { value in
                    if value {
                        if let location = viewModel.closestBusLocation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.smooth) {
                                    proxy.scrollTo(location.nodeid, anchor: .center)
                                }
                            }
                        }
                        isScrollTriggered = false
                    }
                }
            }
        }
    }
    
    // BusStop 리스트
    struct BusStopRow: View {
        let busStop: BusStopLocal  // BusStop을 BusStopLocal로 변경
        let isCurrentLocation: Bool
        let arrivalBusStopID: String
        let alertStop: BusStopLocal?
        var body: some View {
            HStack {
                if isCurrentLocation {
                    Image("tagComponent")
                        .foregroundStyle(.brand)
//                        .padding(.leading, 10)
                        .padding(.leading, 8)
                        .id(busStop.nodeid)
                        .overlay{
                            Text("현위치")
                                .font(.caption2)
                                .foregroundStyle(.brand)
                        }
                } else {
                    Image("tagComponent")
                        .opacity(0)
                        .padding(.leading, 8)
                }
                VStack {
                    if busStop.nodeord == 1 {
                        Image("Line_FirstBusStop")
                    } else if busStop.nodeid == arrivalBusStopID {
                        Image("Line_EndBusStop")
                            .padding(.leading, -3)
                    } else if busStop.nodeid == alertStop?.nodeid {
                        Image("Line_AlertBusStop")
                            .padding(.leading, -4)
                    } else if isCurrentLocation {
                        Image("Line_CurrentBusStop")
                            .padding(.leading, -3)
                    }
                    else {
                        Image("Line_NormalBusStop")
                    }
                }
                Text(busStop.nodenm)
                    .padding(.leading, 22)
                    .foregroundColor(Color.black)
                    .font(isCurrentLocation ? .body1 : .caption1)
                Spacer()
            }
            .frame(height: busStop.nodeid == alertStop?.nodeid ? 88 : 60)
        }
    }
    
    /// 타이머 시작
    private func startRefreshTimer() {
        refreshTimerCancellable = Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                refreshData()
                print("화면 새로고침")
            }
    }
    
    /// 타이머 중단
    private func stopRefreshTimer() {
        refreshTimerCancellable?.cancel()
        refreshTimerCancellable = nil
    }
    
    /// 알람 종료를 위한 Alert 표시
//    private func exitConfirmAlert() -> SwiftUI.Alert {
//        return SwiftUI.Alert(
//            title: Text("알람 종료"),
//            message: Text("알람을 종료하시겠습니까?"),
//            primaryButton: .destructive(Text("종료")) {
//                // 알림 취소
//                stopRefreshTimer() // 알람 종료 시 타이머도 중단
//                notificationManager.notificationReceived = false // 오버레이 닫기
//                locationManager.unregisterBusAlert(busAlert)
//                dismiss() // Dismiss the view if confirmed
//            },
//            secondaryButton: .cancel(Text("취소"))
//        )
//    }
    
    // 새로고침 함수
    func refreshData() {
        guard !isRefreshing else { return } // 이미 새로고침 중일 경우 중복 요청 방지
        isRefreshing = true
        DispatchQueue.global(qos: .background).async {
            currentBusViewModel.fetchBusLocationData(cityCode: Int(busAlert.cityCode), routeId: busAlert.routeid)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                lastRefreshTime = Date() // 새로고침 시간 업데이트
                isRefreshing = false
            }
        }
    }
    
    // 새로고침 버튼 뷰
    struct RefreshButton: View {
        let isRefreshing: Bool
        @Binding var isScrollTriggered: Bool
        var action: () -> Void
        
        var body: some View {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: action) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .padding()
                            .background(Color.black)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .disabled(isRefreshing)
                    .padding()
                }
            }
        }
    }
    
    // 알람 비활성화 뷰
    @ViewBuilder
    func AfterAlertView() -> some View {
        VStack {
            Image("AfterAlertImg")
                .padding()
            
            // 알람 종료 버튼
            Button(action: {
                stopRefreshTimer() // 알람 종료 시 타이머도 중단
                notificationManager.notificationReceived = false // 오버레이 닫기
                locationManager.unregisterBusAlert(busAlert)
                locationManager.stopAudio()
                dismiss()
            }, label: {
                Text("종료")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                    .padding(.horizontal, 20)
                    .background(Capsule().foregroundStyle(Color.black))
            })
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 10)
        .onDisappear{
            locationManager.unregisterBusAlert(busAlert)
            locationManager.stopAllMonitoring()
        }
    }
    
    /// 알람 울릴 버스 정류소 계산
    func findAlertBusStop(busAlert: BusAlert, busStops: [BusStopLocal]) -> BusStopLocal? {
        // 1. BusStopLocal에서 routeid가 동일한 노선 찾기
        let filteredStops = busStops.filter { $0.routeid == busAlert.routeid }
        
        // 2. 도착 정류소 ID에 해당하는 정류소 찾기
        guard let arrivalStop = filteredStops.first(where: { $0.nodeid == busAlert.arrivalBusStopID }) else {
            return nil // 도착 정류소가 없으면 nil 반환
        }
        
        // 3. 도착 정류소의 nodeord에서 alertBusStop을 뺀 정류소 찾기
        let targetNodeOrd = arrivalStop.nodeord - busAlert.alertBusStop
        
        // 4. 해당 nodeord에 해당하는 정류소 반환
        return filteredStops.first(where: { $0.nodeord == targetNodeOrd })
    }
}
