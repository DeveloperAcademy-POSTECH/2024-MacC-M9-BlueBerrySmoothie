import SwiftUI

struct UsingAlertView: View {
    let busStops: [BusStopLocal] // 정류소 정보 배열
    let busAlert: BusAlert // 관련된 알림 정보
    @State private var isAlertEnabled: Bool = false // 스위치 상태 관리
    
    var body: some View {
        VStack {
            VStack {
                VStack{
                    HStack{
                        Text("\(busAlert.busNo)")
                        Image(systemName: "suit.diamond.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.midbrand)
                        Text("\(busAlert.alertLabel)")
                        Spacer()
                    }
                    .font(.title3)
                    .foregroundStyle(.gray2)
                    HStack {
                        Image(systemName: "bell.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(.midbrand)
                        Text("운촌")
                        Toggle(isOn: $isAlertEnabled) {
                            //                        Text("알림 켜기") // 스위치 레이블
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .brand))
                    }
                    .font(.title)
                    HStack{
                        Text("12정류장 후 알림")
                            .foregroundStyle(.gray3)
                        Spacer()
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.top)
                .padding(.bottom, 28)
            }
            .background(.white)
            
            
            
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
        }.navigationTitle("출근하기")
            .background(.doublelightbrand)
    }
}





////프리뷰입니다.
//struct BusStopView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Sample BusStopLocal creation for 10 bus stops
//        let busStops: [BusStopLocal] = [
//            BusStopLocal(id: "1", routeid: "BSB5200002000", nodeid: "BSB178050301", nodenm: "다대포", nodeno: 10281, nodeord: 1, gpslati: 35.049335, gpslong: 128.961602, updowncd: 0),
//            BusStopLocal(id: "2", routeid: "BSB5200002000", nodeid: "BSB177380101", nodenm: "대우아파트", nodeno: 10198, nodeord: 2, gpslati: 35.050022, gpslong: 128.966600, updowncd: 0),
//            BusStopLocal(id: "3", routeid: "BSB5200002000", nodeid: "BSB177380102", nodenm: "몰운대아파트", nodeno: 10196, nodeord: 3, gpslati: 35.050066, gpslong: 128.967505, updowncd: 0),
//            BusStopLocal(id: "4", routeid: "BSB5200002000", nodeid: "BSB177410101", nodenm: "다대포해수욕장", nodeno: 10191, nodeord: 4, gpslati: 35.050057, gpslong: 128.970455, updowncd: 0),
//            BusStopLocal(id: "5", routeid: "BSB5200002000", nodeid: "BSB177380103", nodenm: "신도시", nodeno: 10197, nodeord: 5, gpslati: 35.050100, gpslong: 128.968000, updowncd: 0),
//            BusStopLocal(id: "6", routeid: "BSB5200002000", nodeid: "BSB177380104", nodenm: "다대포중학교", nodeno: 10200, nodeord: 6, gpslati: 35.050200, gpslong: 128.965000, updowncd: 0),
//            BusStopLocal(id: "7", routeid: "BSB5200002000", nodeid: "BSB177410102", nodenm: "하수도", nodeno: 10192, nodeord: 7, gpslati: 35.050300, gpslong: 128.970000, updowncd: 0),
//            BusStopLocal(id: "8", routeid: "BSB5200002000", nodeid: "BSB177410103", nodenm: "다대포마을", nodeno: 10193, nodeord: 8, gpslati: 35.050400, gpslong: 128.971000, updowncd: 0),
//            BusStopLocal(id: "9", routeid: "BSB5200002000", nodeid: "BSB177410104", nodenm: "조수", nodeno: 10194, nodeord: 9, gpslati: 35.050500, gpslong: 128.972000, updowncd: 0),
//            BusStopLocal(id: "10", routeid: "BSB5200002000", nodeid: "BSB177410105", nodenm: "다대포관광안내소", nodeno: 10195, nodeord: 10, gpslati: 35.050600, gpslong: 128.973000, updowncd: 0)
//        ]
//
//        let alert = Alert(id: "1", cityCode: 12345, busNo: "43", routeid: "BSB5200002000", arrivalBusStopID: "BSB178050301", alertBusStop: 1, alertLabel: "재윤이의 행복한 출근길", alertSound: true, alertHaptic: true, alertCycle: 5.0)
//
//        // 미리보기에서 사용할 정류소 배열
//        UsingAlertView(busStops: busStops, alert: alert)
//    }
//}
