//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
//    // FetchRequest를 사용하여 저장된 BusAlert 데이터 불러오기
//    @Environment(\.modelContext) private var modelContext
//    @Query var busAlerts: [BusAlert] // BusAlert 모델을 쿼리합니다.
//    @Query var busStopLocal: [BusStopLocal]
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                NavigationLink(destination: AlertSettingMain()) {
//                    HStack {
//                        Image(systemName: "location.fill") // 도시 선택 심볼
//                            .resizable()
//                            .frame(width: 24, height: 24)
//                        Text("Select City")
//                            .font(.headline)
//                    }
//                    .padding()
//                    .background(Color.blue.opacity(0.2))
//                    .cornerRadius(10)
//                }
//                List(busAlerts) { alert in
//                    NavigationLink(destination: DetailView(alert: alert)) {
//                        VStack(alignment: .leading) {
//                            Text(alert.alertLabel)
//                                .font(.headline)
//                            Text("버스 번호: \(alert.busNo)")
//                            Text("도시 코드: \(alert.cityCode)")
//                            Text("정류장 ID: \(alert.arrivalBusStopID)")
//                            Text("정류장 ID: \(alert.arrivalBusStopNm)")
//                        }
//                                      }
//                               
//                           }
//                
//                List(busStopLocal) { busstop in
//                               VStack(alignment: .leading) {
//                                   Text(busstop.nodeid)
//                                       .font(.headline)
//                                   Text("버스 번호: \(busstop.nodenm)")
//                                   Text("도시 코드: \(busstop.gpslati)")
//                                   Text("정류장 ID: \(busstop.gpslong)")
//                               }
//                           }
//
//                NavigationLink(destination: SelectCityView()) { // StartAlarmView를 추가하세요
//                    HStack {
//                        Image(systemName: "alarm.fill") // 알람 시작 심볼
//                            .resizable()
//                            .frame(width: 24, height: 24)
//                        Text("Start Alarm")
//                            .font(.headline)
//                    }
//                    .padding()
//                    .background(Color.green.opacity(0.2))
//                    .cornerRadius(10)
//                }
//                
//               
//            }
//            .padding()
//            .navigationTitle("Main Menu")
//        }
//    }
//}
//
