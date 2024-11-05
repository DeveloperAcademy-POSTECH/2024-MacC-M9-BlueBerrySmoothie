

import SwiftUI

struct SelectBusStopView: View {
    @EnvironmentObject var busStopViewModel: BusStopViewModel

    let city: City // 도시 정보
    let bus: Bus // 선택된 버스 정보
//    @Binding var selectedBus: Bus?
    @Binding var selectedBusStop: BusStop? // 상위 뷰에 선택된 정류장 전달을 위한 바인딩
    @Binding var allBusStops: [BusStop]
    
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
                    // 정류장 선택 시
//                    selectedBus = bus
                    selectedBusStop = busStop // 상위 뷰에 선택된 정류장 전달
                    allBusStops = busStopViewModel.busStopList
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
            print("\(bus.routeno)\n\n\n\n\n\n\n\n\n\n\n")
            // 최신 버스 데이터를 기반으로 버스 정류장 데이터 로드
            await loadBusStops()
            print("\(bus.routeno)\n\n\n\n\n\n\n\n\n\n\n\n\n")
            
        }
       
       
    }
    
    private func loadBusStops() async {
        do {
            try await busStopViewModel.getBusStopData(cityCode: city.citycode, routeId: bus.routeid)
        } catch {
            print("Error loading bus stop data: \(error)") // 오류 핸들링
        }
    }
}
