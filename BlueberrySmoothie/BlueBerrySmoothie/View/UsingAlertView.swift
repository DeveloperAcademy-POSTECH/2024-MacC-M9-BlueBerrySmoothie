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
    var EndAlertLottie = LottieManager(filename: "AlarmLottie", loopMode: .loop)
    @State private var liveActivityManager: LiveActivityManager? = nil
    
    var body: some View {
        ZStack {
            Color.usingAlertViewBG
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

                       
                        
                    }, isScrollTriggered: $isScrollTriggered

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
                .edgesIgnoringSafeArea(.bottom)
            }
            .onDisappear {
                LiveActivityManager.shared.endLiveActivity()
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
                    .toolbar(.hidden) // 알람종료 뷰에서는 툴바 숨기기
            }
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
                        .foregroundStyle(.gray1Dgray6)
                })
            }
        }
        .alert("알람 종료", isPresented: $showExitConfirmation) {
            Button("종료", role: .destructive) {
                // 알림 취소
                stopRefreshTimer() // 알람 종료 시 타이머도 중단
                notificationManager.notificationReceived = false // 오버레이 닫기
                locationManager.unregisterBusAlert(busAlert)
                LiveActivityManager.shared.endLiveActivity()
                dismiss() // Dismiss the view if confirmed
            }
            Button("취소", role: .cancel){}
        } message: {
            Text("알람을 종료하시겠습니까?")
        }
        .onAppear {
            refreshData() // 초기 로드
            currentBusViewModel.startUpdating() // 뷰가 보일 때 뷰모델에서 위치 업데이트 시작
            startRefreshTimer() // 타이머 시작
            //            notificationManager.notificationReceived = true

        }
        .onChange(of: currentBusViewModel.closestBusLocation?.nodeid) { closestBusNodeId in
            if let closestBusNodeId = closestBusNodeId,
               busStops.contains(where: { $0.nodeid == closestBusNodeId }) {
                print("온체인지 감지 - closestBus가 busStops에 있음")
                isFinishedLoading = true
                isScrollTriggered = true
                print(isFinishedLoading)
                print(isScrollTriggered)
            }
        }
        .onDisappear {
            LiveActivityManager.shared.endLiveActivity()
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
        @State var refreshButtonLottie = LottieManager(filename: "refreshLottie", loopMode: .playOnce)
        @Binding var isScrollTriggered: Bool // 스크롤하게 하는 트리거
        @State private var isRefreshDisabled = false // 5초 동안 새로고침 비활성화 상태를 추적
        
        var body: some View {
            ZStack {
                Image("BusAlertInfoBG")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: 224)
                
                VStack(alignment: .leading, spacing: 3) {
                    // 버스 정보
                    HStack(spacing: 4) {
                        Image(systemName: "square.fill")
                            .foregroundStyle(busColor(for: busAlert.routetp))
                            .frame(width: 12, height: 12)
                        
                        Text("\(busAlert.busNo)")
                            .font(.caption2)
                            .foregroundStyle(.gray3Dgray6)
                        
                        Rectangle()
                            .frame(width: 2, height: 8)
                            .foregroundStyle(.gray3Dgray6)
                        
                        Text(busAlert.arrivalBusStopNm)
                            .font(.caption2)
                            .foregroundStyle(.gray3Dgray6)
                    }.padding(.bottom, 16)
                    
                    // 현재 위치 정보
                    if let closestBus = viewModel.closestBusLocation {
                        Text("알람까지 \(busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0) - 1 ) 정류장 남았습니다.")
                            .font(.title2)
                            .foregroundStyle(.blackDGray7)
                            .padding(.bottom, 10)
                        
                        Text("현재 정류장은")
                            .font(.caption1)
                            .foregroundStyle(.gray1Dgray6)
                        HStack(spacing: 2){
                            Text("\(closestBus.nodenm)")
                                .font(.caption1)
                                .foregroundStyle(.brand)
                            Text("입니다.")
                                .font(.caption1)
                                .foregroundStyle(.gray1)
                                .onAppear {
                                    LiveActivityManager.shared.startLiveActivity(title: busAlert.alertLabel ?? "알 수 없는 알람" , description: busAlert.busNo, stationName: busAlert.arrivalBusStopNm, initialProgress: 99, currentStop: closestBus.nodenm, stopsRemaining: busAlert.arrivalBusStopNord - (Int(closestBus.nodeord) ?? 0) - 1 )
                                }
                        }
                    }
                    
                    //새로고침 시간, 새로고침 버튼
                    HStack(spacing: 8){
                        Spacer()
                        if let lastRefreshTime = lastRefreshTime {
                            Text(formattedTime(from: lastRefreshTime))
                                .font(.caption2)
                                .foregroundStyle(.gray3Dgray6)
                        }

                        refreshButtonLottie
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                // 새로고침 비활성화 상태인지 확인
                                guard !isRefreshDisabled else {
                                    // 비활성화 상태라면, 스크롤 동작만 트리거하고 종료
                                    isScrollTriggered = true
                                    return
                                }
                                
                                // 새로고침 로직 실행
                                refreshAction() // 새로고침 동작을 수행하는 사용자 정의 함수 호출
                                isScrollTriggered = true // 스크롤 트리거 활성화
                                isRefreshDisabled = true // 새로고침 비활성화 설정

                                // 애니메이션 제어
                                refreshButtonLottie.stop() // 버튼 클릭 시 기존 애니메이션 멈춤
                                print("ㅋㅋ") // 디버깅 메시지 출력
                                refreshButtonLottie.play() // 버튼 클릭 시 새 애니메이션 실행

                                // 햅틱 피드백 (진동 효과) 트리거
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    HapticManager.shared.triggerImpactFeedback(style: .medium) // 중간 강도의 햅틱 효과 실행
                                }

                                // 5초 후 새로고침 버튼 다시 활성화
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    isRefreshDisabled = false // 비활성화 플래그 해제
                                }
                            }
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
                            let filteredBusStops = busStops.filter { $0.routeid == busAlert.routeid }
                                .sorted(by: { $0.nodeord < $1.nodeord })
                            let maxNodeord = filteredBusStops.last?.nodeord // 마지막 정류장의 nodeord
                            
                            ForEach(filteredBusStops, id: \.id) { busStop in
                                BusStopRow(
                                    busStop: busStop,
                                    isCurrentLocation: busStop.nodeid == closestBus.nodeid,
                                    arrivalBusStopID: busAlert.arrivalBusStopID,
                                    alertStop: alertStop,
                                    isLastBusStop: busStop.nodeord == maxNodeord, // 현재 정류장의 nodeord가 최대값과 같은지 비교
                                    alertLabel: busAlert.alertLabel
                                )
                            }
                        } else if isRefreshing {
                            // 로딩 중일 때 로딩 인디케이터 표시
                            ProgressView("가장 가까운 버스 위치를 찾고 있습니다...")
                                .foregroundColor(Color.black)
                                .font(.caption1)
//                            AlertLoadingView()
                        } else {
                            Text("가장 가까운 버스 위치를 찾고 있습니다...")
                                .foregroundColor(Color.black)
                                .font(.caption1)
                            //                            AlertLoadingView()

                        }
                        Spacer()
                    }
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
        let alertLabel: String? // 추가된 busAlertLabel
        
        var body: some View {
            HStack {
                if isCurrentLocation {
                    Image("tagComponent")
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
                VStack(alignment: .leading){
                    Text(busStop.nodenm)
                        .padding(.leading, 20)
                        .foregroundStyle(.gray1Dgray6)
                        .font(isCurrentLocation || busStop.nodeid == arrivalBusStopID || busStop.nodeid == alertStop?.nodeid ? .body1 : .caption1)
                    if busStop.nodeid == alertStop?.nodeid {
                        // TODO: 알람 레이블 여기 넣기
                        HStack{
                            Rectangle()
                                .frame(minWidth: 34, maxHeight: 23)
                                .fixedSize(horizontal: true, vertical: false)
                                .foregroundColor(Color.lightbrand)
                                .cornerRadius(4)
                                .overlay {
                                    Text(alertLabel ?? "") // alertLabel 표시
                                        .font(.caption2)
                                        .padding(4)
                                        .foregroundColor(Color.brand)
                                }
                                .padding(.leading, 20)
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            .frame(height: busStop.nodeid == alertStop?.nodeid ? 88 : 60)
            .background(busStop.nodeid == arrivalBusStopID || busStop.nodeid == alertStop?.nodeid ? .gray7DGray1 : .whiteDBlack)
        }
    }
    
    /// 타이머 시작
    private func startRefreshTimer() {
        refreshTimerCancellable = Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                refreshData()
                LiveActivityManager.shared.updateLiveActivity(progress: 0.5, currentStop: currentBusViewModel.closestBusLocation?.nodenm ?? "로딩중", stopsRemaining: busAlert.arrivalBusStopNord - (Int(currentBusViewModel.closestBusLocation?.nodeord ?? "0") ?? 0) - 1)
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
        ZStack {
            Image("AfterAlertViewBG")
                .resizable()
                .ignoresSafeArea()
            
            // 둥근 모서리의 반투명한 직사각형과 텍스트
            VStack {
                EndAlertLottie
                    .scaleEffect(2.8) // 크기 조절
                
                Button(action: {
                    stopRefreshTimer() // 알람 종료 시 타이머도 중단
                    notificationManager.notificationReceived = false // 오버레이 닫기
                    locationManager.unregisterBusAlert(busAlert)
                    locationManager.stopAudio()
                    dismiss()
                }, label: {
                    Text("알람 종료")
                        .frame(width: 133, height: 49)
                        .foregroundStyle(.white)
                        .font(.title2)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.blackDBrand))
                    
                })
                .padding(.bottom, 48)
                
            }
            .background(
                Image("AfterAlertRectangle")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: 500)
            )
            .padding(.horizontal, 20)
            .padding(.top, 120)
            .padding(.bottom, 150)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear {
            locationManager.unregisterBusAlert(busAlert)
            locationManager.stopAllMonitoring()
        }
        .onAppear {
            EndAlertLottie.play()
        }
    }
}
