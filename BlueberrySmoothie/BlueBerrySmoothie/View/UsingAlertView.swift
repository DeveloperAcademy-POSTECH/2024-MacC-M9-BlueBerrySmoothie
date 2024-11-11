import SwiftUI
import SwiftData

struct UsingAlertView: View {
    //    let busStops: [BusStopLocal] // 정류소 정보 배열
    @Query var busStops: [BusStopLocal]
    @StateObject private var viewModel = NowBusLocationViewModel() // ViewModel 연결
    let busAlert: BusAlert // 관련된 알림 정보
    let alertBusStopLocal: BusStopLocal // 알림 기준 정류소
    let arrivalBusStopLocal: BusStopLocal // 도착 정류소
    @Environment(\.dismiss) private var dismiss
    @State private var isAlertEnabled: Bool = false // 스위치 상태 관리
    // NotificationManager 인스턴스 감지
    @ObservedObject var notificationManager = NotificationManager.instance
    // EndView로의 이동 상태를 관리하는 변수
    @State private var navigateToEndView = false
    @State private var isRefreshing: Bool = false // 새로고침 상태 관리
    @State private var lastRefreshTime: Date? = nil // 마지막 새로고침 시간
    @State private var showExitConfirmation = false
    
    // 타이머 설정: 10초마다 자동으로 새로고침
    private let refreshTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 기존 콘텐츠 부분
            VStack {
                
                VStack {
                    HStack {
                        Button(action: {self.showExitConfirmation.toggle(); print(showExitConfirmation)}, label: {Image(systemName: "xmark").foregroundStyle(.black)})
                        
                        Spacer()
                    }
                    .alert(isPresented: $showExitConfirmation) {
                        SwiftUI.Alert(
                                        title: Text("알람 종료"),
                                        message: Text("알람을 종료되고 메인화면으로 돌아가요"),
                                        primaryButton: .destructive(Text("종료")) {
                                            // 알림 취소 (alertBusStopLocal과 arrivalBusStopLocal 각각에 대해 호출)
                                            notificationManager.cancelLocationNotification(for: busAlert, for: alertBusStopLocal)
                                            notificationManager.cancelLocationNotification(for: busAlert, for: arrivalBusStopLocal)
                                            dismiss() // Dismiss the view if confirmed
                                        },
                                        secondaryButton: .cancel(Text("취소")))
                                    
                                }
                    .padding(.horizontal, 20)
                    VStack {
                        HStack {
                            Text("\(busAlert.busNo)")
                                .foregroundColor(Color.gray3)
                                .font(.regular20)
                            Image(systemName: "suit.diamond.fill")
                                .font(.regular10)
                                .foregroundStyle(.midbrand)
                            Text("\(busAlert.arrivalBusStopNm)")
                                .foregroundColor(Color.gray2)
                                .font(.regular20)
                            Spacer()
                        }
                        .padding(.bottom, 26)
                        
                        HStack {
                            Text("\(busAlert.alertBusStop)정류장 전 알림")
                                .foregroundStyle(.brand)
                                .font(.regular16)
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
                            Text("\(busAlert.alertBusStopNm)")
                                .foregroundColor(Color.black)
                                .font(.medium30)
                            Spacer()
                        }

                    }
                    .padding(.horizontal, 20)
                    .padding(.top)
                    .padding(.bottom, 28)
                }
                

                .background(Color.lightbrand)
                   
                //버스 노선 스크롤뷰
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        if let closestBus = viewModel.closestBusLocation {
                            ForEach(busStops.filter { $0.routeid == busAlert.routeid }.sorted(by: { $0.nodeord < $1.nodeord }), id: \.id) { busStop in
                                HStack {
                                    if busStop.nodeid == closestBus.nodeid {
                                        Image(systemName: "bus.fill")
                                            .foregroundStyle(.brand)
                                            .padding(.leading, 10)
                                    } else {
                                        Image(systemName: "bus.fill")
                                            .opacity(0)
                                            .padding(.leading, 10)
                                    }
                                    VStack {
                                        if busStop.nodeid == busAlert.arrivalBusStopID {
                                            Image("endpoint")
                                                .frame(width: 20, height: 20)
                                        } else {
                                            Rectangle()
                                                .frame(width: 1)
                                                .foregroundStyle(.gray5)
                                            ZStack {
                                                Circle()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(Color.gray6)
                                                Circle()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(Color.lightbrand)
                                                
                                                Image(systemName: "chevron.down")
                                                    .foregroundStyle(busStop.nodeid == closestBus.nodeid ? .red : .gray4)
                                                    .font(.regular10)
                                                    .bold()
                                                    .padding(.vertical, 2)
                                            }
                                            Rectangle()
                                                .frame(width: 1)
                                                .foregroundStyle(.gray5)
                                        }
                                    }
                                    .foregroundStyle(.gray)
                                    .padding(.leading, 10)
                                    
                                    Text(busStop.nodenm) // 정류소 이름 표시
                                        .padding(.leading, 25)
                                        .foregroundColor(Color.black)
                                        .font(.regular16)
                                    Spacer()
                                }
                                .frame(height: 60)
                            }
                        } else if isRefreshing {
                            // 로딩 중일 때 로딩 인디케이터 표시
                            ProgressView("가장 가까운 버스 위치를 찾고 있습니다...")
                                .foregroundColor(Color.black)
                                .font(.regular16)
                        } else {
                            Text("가장 가까운 버스 위치를 찾고 있습니다...")
                                .foregroundColor(Color.black)
                                .font(.regular16)
                        }
                        Spacer()

                    }
                    .background(.clear)
                }
                
            }
            .background(Color.gray7)
            .navigationTitle(busAlert.alertLabel ?? "알람")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                refreshData() // 초기 로드
            }
            
            // 타이머를 활용한 자동 새로고침
            .onReceive(refreshTimer) { _ in
                refreshData()
            }
            

// 새로고침 버튼을 화면 오른쪽 아래에 배치
            VStack {
                Spacer() // 화면 상단에 공간을 줘서 버튼을 하단으로 밀어냄
                HStack {
                    Spacer() // 오른쪽에 공간을 두어 버튼을 오른쪽 끝에 오도록 함
                    Button(action: refreshData) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .padding()
                            .background(Color.black) // 배경색을 검정색으로 설정
                            .clipShape(Circle())
                            .foregroundColor(.white) // 화살표 색상 유지 (하얀색)
                    }
                    .disabled(isRefreshing) // 로딩 중에는 비활성화
                    .padding() // 버튼과 화면 가장자리를 분리
                }
            }
            .padding()
            
            // 알람종료 오버레이 뷰
            if notificationManager.notificationReceived {
                AfterAlertView()
                    .edgesIgnoringSafeArea(.all) // 전체 화면에 적용
            }
            
            // EndView로의 네비게이션
            NavigationLink(destination: EndViewDaisy(busAlert: busAlert), isActive: $navigateToEndView) {
                EmptyView()
            }
        }
        .toolbar(.hidden)
       
    }
    // 새로고침 함수
    func refreshData() {
        guard !isRefreshing else { return } // 이미 새로고침 중일 경우 중복 요청 방지
        isRefreshing = true
        DispatchQueue.global(qos: .background).async {
            viewModel.fetchBusLocationData(cityCode: 21, routeId: busAlert.routeid)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                lastRefreshTime = Date() // 새로고침 시간 업데이트
                isRefreshing = false
            }
        }
    }
    
    @ViewBuilder
    func AfterAlertView() -> some View {
        VStack {
            Image("AfterAlertImg")
                .padding()
            
            Button(action: {
                notificationManager.notificationReceived = false // 오버레이 닫기
                
                // 알림 취소 (alertBusStopLocal과 arrivalBusStopLocal 각각에 대해 호출)
                notificationManager.cancelLocationNotification(for: busAlert, for: alertBusStopLocal)
                notificationManager.cancelLocationNotification(for: busAlert, for: arrivalBusStopLocal)
                dismiss()
            //                notificationManager.locationManager.stopLocationUpdates()
            }, label: {
                Text("종료")
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                    .padding(.horizontal, 20)
                    .background(Capsule())
            })
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 10)
        
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
}
