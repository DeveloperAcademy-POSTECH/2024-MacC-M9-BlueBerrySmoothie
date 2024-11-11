import SwiftUI
import SwiftData

struct UsingAlertView: View {
    //    let busStops: [BusStopLocal] // 정류소 정보 배열
    @Query var busStops: [BusStopLocal]
    let busAlert: BusAlert // 관련된 알림 정보
    let alertBusStopLocal: BusStopLocal // 알림 기준 정류소
    let arrivalBusStopLocal: BusStopLocal // 도착 정류소
    
    @State private var isAlertEnabled: Bool = false // 스위치 상태 관리
    // NotificationManager 인스턴스 감지
    @ObservedObject var notificationManager = NotificationManager.instance
    // EndView로의 이동 상태를 관리하는 변수
    @State private var navigateToEndView = false
    
    var body: some View {
        ZStack{
            VStack {
                VStack {
                    VStack{
                        HStack{
                            Text(busAlert.busNo)
                            Image(systemName: "suit.diamond.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.midbrand)
                            Text(busAlert.alertLabel)
                            Spacer()
                        }
                        .font(.title3)
                        .foregroundStyle(.gray2)
                        HStack {
                            Image(systemName: "bell.circle")
                                .font(.system(size: 20))
                                .foregroundStyle(.midbrand)
                            Text(busAlert.arrivalBusStopNm)
                            Toggle(isOn: $isAlertEnabled) {
                                //                        Text("알림 켜기") // 스위치 레이블
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .brand))
                        }
                        .font(.title)
                        HStack{
                            Text("\(busAlert.alertBusStop) 정류장 후 알림")
                                .foregroundStyle(.gray3)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top)
                    .padding(.bottom, 28)
                }
                .background(.white)
                
                //버스 노선 스크롤뷰
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(busStops, id: \.id) { busStop in
                            HStack{
                                //                            Image(systemName: "dot.circle")
                                VStack {
                                    Rectangle()
                                        .frame(width: 1) // 선의 너비
                                        .foregroundStyle(.gray5)
                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(.brand)
                                        .font(.system(size: 5))
                                        .padding(.vertical, 2)
                                    Rectangle()
                                        .frame(width: 1) // 선의 너비
                                        .foregroundStyle(.gray5)
                                }
                                .foregroundStyle(.gray)
                                .padding(.leading, 40)
                                
                                
                                Text(busStop.nodenm) // 정류소 이름 표시
                                    .padding(.leading, 25)
                                    .font(.system(size: 16))
                                Spacer()
                            }
                            .frame(height: 60)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle(busAlert.alertLabel)
            //        .background(Color.black)
            
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
                // EndView로 이동
                navigateToEndView = true
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

}
