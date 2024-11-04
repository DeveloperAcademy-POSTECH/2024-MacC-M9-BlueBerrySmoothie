//
//  SelectBusStopView.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/31/24.
//

import SwiftUI

struct SelectBusStopView: View {
    @EnvironmentObject var busStopViewModel: BusStopViewModel
    
    let city: City // 도시
    let bus: Bus // 버스
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text("도시 이름: \(city.cityname)")
            Text("도시 코드: \(city.citycode)")
                .foregroundColor(.gray)
            Text("버스 번호: \(bus.routeno)")
                .foregroundColor(.gray)
            Text("노선 ID: \(bus.routeid)")
                .foregroundColor(.gray)
            
            Text("상행:0 ,하행:1")
            List {
                ForEach(busStopViewModel.busStopList, id: \.self) { busStop in
                    Button(action: {
                        print("Button 1")
                        var alert: Alert = Alert(cityCode: city.citycode, bus: bus, arrivalBusStop: busStop, alertBusStop: 3, alertLabel: "Test")
                        
                        // 상행의 최대 순번 구하기
                        if let maxUpwardNodeord = busStopViewModel.busStopList.filter({ $0.updowncd == 0 }).map({ $0.nodeord }).max() {
                            
                            // 이전 정류장 (1~3번째) 저장
                            storeBeforeBusStops(for: busStop, alert: &alert, busStops: busStopViewModel.busStopList, maxUpwardNodeord: maxUpwardNodeord)
                        }
                        
                        //                        print(alert)
                        print(alert.arrivalBusStop)
                        print(alert.firstBeforeBusStop ?? nil)
                        print(alert.secondBeforeBusStop ?? nil)
                        print(alert.thirdBeforeBusStop ?? nil)
                        
                    }){
                        VStack(alignment: .leading) {
                            Text("정류소ID: \(busStop.nodeid)")
                            Text("정류소명: \(busStop.nodenm)")
                            Text("정류소번호: \(busStop.nodeno ?? 0)")
                            Text("정류소순번: \(busStop.nodeord)")
                            Text("x,y 좌표: \(busStop.gpslati), \(busStop.gpslong)")
                            Text("상하행구분코드: \(busStop.updowncd)")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("버스정류장들 정보")
        .task {
            await busStopViewModel.getBusStopData(cityCode: city.citycode, routeId: bus.routeid)

        }
    }
    
    private func storeBeforeBusStops(for busStop: BusStop, alert: inout Alert, busStops: [BusStop], maxUpwardNodeord: Int) {
        
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
        
        
        // 이전 정류장을 최대 3개까지 저장함
        // beforeBusStop이 nil이면 선택지에서 비활성화 되어있게 하는 것도 좋을듯
        alert.firstBeforeBusStop = currentIndex > 1 ? busStops[busStop.nodeord - 2] : nil
        alert.secondBeforeBusStop = currentIndex > 2 ? busStops[busStop.nodeord - 3] : nil
        alert.thirdBeforeBusStop = currentIndex > 3 ? busStops[busStop.nodeord - 4] : nil
    }
}


