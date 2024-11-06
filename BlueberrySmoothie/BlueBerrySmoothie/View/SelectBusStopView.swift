

import SwiftUI
//
//struct SelectBusStopView: View {
    @EnvironmentObject var busStopViewModel: BusStopViewModel
    
    let city: City // 도시 정보
    let bus: Bus // 선택된 버스 정보
    @Binding var busStopAlert: BusStopAlert?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // 기본 정보 출력
            Text("도시: \(city.cityname)")
            Text("버스 번호: \(bus.routeno)")
                .font(.headline)
                .foregroundColor(.blue)
            Text("노선 ID: \(bus.routeid)")
                .foregroundColor(.gray)
            
            // 정류장 목록 출력
            List(busStopViewModel.busStopList, id: \.self) { busStop in
                Button(action: {
                    // 정류장 저장
                    storeBusStop(busStop: busStop)
                    dismiss()
                }) {
                    // 정류장 정보를 표시하는 뷰
                    VStack(alignment: .leading) {
                        Text("정류소 ID: \(busStop.nodeid)")
                        Text("정류소 이름: \(busStop.nodenm)")
                        Text("정류소 번호: \(busStop.nodeno ?? 0)")
                        Text("정류소 순번: \(busStop.nodeord)")
                    }
                }
            }
            .listStyle(PlainListStyle()) // 플레인 스타일의 리스트 사용
        }
        .padding()
        .navigationTitle("정류장 선택")
        .task {
            // 최신 버스 데이터를 기반으로 버스 정류장 데이터 로드
            //            await loadBusStops()
            await busStopViewModel.getBusStopData(cityCode: city.citycode, routeId: bus.routeid)
        }
        
        
    }
    
    //    private func loadBusStops() async {
    //        do {
    //            try await busStopViewModel.getBusStopData(cityCode: city.citycode, routeId: bus.routeid)
    //        } catch {
    //            print("Error loading bus stop data: \(error)") // 오류 핸들링
    //        }
    //    }
    
    func storeBusStop(busStop: BusStop){
        // 상행의 가장 큰 order 구함
        if let maxUpwardNodeord = busStopViewModel.busStopList.filter({ $0.updowncd == 0 }).map({ $0.nodeord }).max() {
            
            // 기본 busStopAlert 데이터 저장
            busStopAlert = BusStopAlert(cityCode: Double(city.citycode), bus: bus, allBusStop: busStopViewModel.busStopList, arrivalBusStop: busStop, alertBusStop: 0)
            
            // 이전 정류장 (1~3번째) 저장
            if var unwrappedBusStopAlert = busStopAlert {
                storeBeforeBusStops(for: busStop, alert: &unwrappedBusStopAlert, busStops: busStopViewModel.busStopList, maxUpwardNodeord: maxUpwardNodeord)
            }
        }
    }
    
    private func storeBeforeBusStops(for busStop: BusStop, alert: inout BusStopAlert, busStops: [BusStop], maxUpwardNodeord: Int) {
        
        let currentIndex: Int // 선택한 정류장 이전의 정류장이 몇 개 남아있는지 확인하는 용도
        
        // 현재 정류장이 상행이면
        if busStop.updowncd == 0 {
            // 상행의 순번을 넣고
            currentIndex = busStop.nodeord
        } else { // 현재 정류장이 하행이면
            // 하행의 순번에서 상행의 최대 순번을 뺀다
            // 최대 순번을 뺀 수가 3이하일 경우를 아래 이전 정류장 저장 부분에서 처리하기 위함
            currentIndex = busStop.nodeord - maxUpwardNodeord
        }
        
        //일반적인 경우엔 위의 과정을 거쳐와도 currentIndex가 3보다 작지 않기 때문에 아무 상관 없음
        
        // 이전 정류장을 최대 3개까지 저장함
        // beforeBusStop이 nil이면 선택지에서 비활성화 되어있게 하는 것도 좋을듯
        // nodeord가 1부터 시작해서 n+1 만큼 빼주어야함
        alert.firstBeforeBusStop = currentIndex > 1 ? busStops[busStop.nodeord - 2] : nil
        alert.secondBeforeBusStop = currentIndex > 2 ? busStops[busStop.nodeord - 3] : nil
        alert.thirdBeforeBusStop = currentIndex > 3 ? busStops[busStop.nodeord - 4] : nil
    }
}
