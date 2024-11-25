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
            Color.lightbrand
                .ignoresSafeArea()
            
            VStack {
                // 상단 네모박스 정보 뷰
                BusAlertInfoView(
                    busAlert: busAlert,
                    alertStop: alertStop,
                    isRefreshing: $isRefreshing,
                    viewModel: currentBusViewModel,
                    lastRefreshTime: $lastRefreshTime,
                    refreshAction: {
                        refreshData()
                        isScrollTriggered = true // 스크롤 동작 트리거
                    }
                ).padding(10)
                    .padding(.trailing, -8)
                    .padding(.top, -10)
                
                // 노션뷰
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
            .navigationBarBackButtonHidden()
            .navigationTitle(busAlert.alertLabel ?? "알람")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // x 버튼
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.showExitConfirmation.toggle();
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    })
                }
            }
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
            .onDisappear {
                currentBusViewModel.stopUpdating() // 뷰가 사라질 때 뷰모델에서 위치 업데이트 중단
                stopRefreshTimer() // 뷰 사라질 때 타이머 중단
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
        @ObservedObject var viewModel: NowBusLocationViewModel // ViewModel을 상위 뷰에서 전달받도록 변경
        @Binding var lastRefreshTime: Date? // 상위 뷰에서 전달받은 값
        var refreshAction: () -> Void // 새로고침 액션 전달받기
        
        var body: some View {
            ZStack {
                Image("BusAlertInfoBG")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: 224)

                VStack(alignment: .leading) {
                    // 버스 정보
                    HStack {
                        Image(systemName: "square.fill")
                            .foregroundStyle(.brand)
                            .frame(width: 12, height: 12)
                        
                        Text("\(busAlert.busNo)번")
                            .font(.caption2)
                            .foregroundStyle(.gray3)
                        
                        Rectangle()
                            .frame(width: 2, height: 8)
                            .foregroundStyle(.gray3)
                        
                        Text(busAlert.arrivalBusStopNm)
                            .font(.caption2)
                            .foregroundStyle(.gray3)
                    }.padding(.bottom, 16)
                    
                    // 현재 위치 정보
                    if let closestBus = viewModel.closestBusLocation {
                        Text("알람까지 \(busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0) - 1 ) 정류장 남았습니다.")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .padding(.bottom, 13)
                        
                        Text("현재 정류장은")
                            .font(.caption1)
                            .foregroundStyle(.gray1)
                        HStack{
                            Text("\(closestBus.nodenm)")
                                .font(.caption1)
                                .foregroundStyle(.brand)
                            Text("입니다.")
                                .font(.caption1)
                                .foregroundStyle(.gray1)
                        }
                    }
                    
                    //새로고침 시간, 새로고침 버튼
                    HStack{
                        Spacer()
                        if let lastRefreshTime = lastRefreshTime {
                            Text(formattedTime(from: lastRefreshTime))
                                .font(.caption2)
                                .foregroundStyle(.gray3)
                        }
                        Button(action: refreshAction) {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(isRefreshing ? .gray3 : .gray1)
                        }
                        .disabled(isRefreshing)
                    }
                    .padding(.trailing, 8)
                }
                .padding(24)
            }
        }
        /// 시간 포맷팅 함수
        private func formattedTime(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
            formatter.dateFormat = "a h:mm" // 오전/오후 h:mm 형식
            return formatter.string(from: date)
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
                                    alertStop: alertStop,
                                    isLastBusStop: busStop.nodeord == busStops.last?.nodeord
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
                    .background(.white)
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
        let isLastBusStop: Bool
        
        var body: some View {
            HStack {
                if isCurrentLocation {
                    Image("tagComponent")
                        .foregroundStyle(.brand)
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
                    } else if isLastBusStop {
                        Image("Line_LastBusStop")
                    }
                    else {
                        Image("Line_NormalBusStop")
                    }
                }
                Text(busStop.nodenm)
                    .padding(.leading, 20)
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
        ZStack{
            Image("AfterAlertViewBG")
                .edgesIgnoringSafeArea(.all)
            
            RoundedRectangle(cornerRadius: 40)
                .background(.thinMaterial)
                .padding(.horizontal, 20)
                .padding(.vertical, 130)
                .overlay{
                    //로띠.
                    // 일단 아무거나 넣음
                    VStack{
                        Image("OnboardingEndView")
                        
                        Spacer()
                        
                        Button(action: {
                            stopRefreshTimer() // 알람 종료 시 타이머도 중단
                            notificationManager.notificationReceived = false // 오버레이 닫기
                            locationManager.unregisterBusAlert(busAlert)
                            locationManager.stopAudio()
                            dismiss()
                        }, label: {
                            Text("알람종료")
                                .foregroundStyle(.white)
                                .font(.title2)
                                .padding()
                                .padding(.horizontal, 22)
                                .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(.black))
                                .frame(width: 135, height: 44)
                        })
                    }
                }
            
//            VStack {
//                Image("AfterAlertImg")
//                    .padding()
//                
//                // 알람 종료 버튼
//                Button(action: {
//                    stopRefreshTimer() // 알람 종료 시 타이머도 중단
//                    notificationManager.notificationReceived = false // 오버레이 닫기
//                    locationManager.unregisterBusAlert(busAlert)
//                    locationManager.stopAudio()
//                    dismiss()
//                }, label: {
//                    Text("알람종료")
//                        .foregroundStyle(.white)
//                        .font(.title2)
//                        .padding()
//                        .padding(.horizontal, 22)
//                        .background(RoundedRectangle(cornerRadius: 8).foregroundStyle(.black))
//                        .frame(width: 135, height: 44)
//                })
//                
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
