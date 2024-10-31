//
//  SelectBusView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 10/31/24.
//

import SwiftUI

// 도시 정보를 선택하는 뷰
struct SelectBusView: View {
    let city: City // 도시 정보
    @State private var buses: [Bus] = [] // 버스 목록을 저장하는 상태 변수
    @State private var routeNo: String = "" // 입력된 노선 번호를 저장하는 상태 변수

    var body: some View {
        VStack(spacing: 20) {
            Text("도시 이름: \(city.cityname)") // 도시 이름 표시
                .font(.largeTitle)
            Text("도시 코드: \(city.citycode)") // 도시 코드 표시
                .font(.title2)
                .foregroundColor(.gray)

            TextField("노선 번호 입력", text: $routeNo) // 노선 번호 입력 필드
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("버스 노선 가져오기") { // 버튼 클릭 시
                fetchBusData(citycode: city.citycode, routeNo: routeNo) { fetchedBuses in
                    self.buses = fetchedBuses // 가져온 버스 목록으로 업데이트
                    print(fetchedBuses)
                }
            }
            .padding()

            List(buses) { bus in // 버스 목록을 리스트로 표시
                NavigationLink(destination: SelectBusStopView(city: city, bus: bus)) {
                    VStack(alignment: .leading) {
                        Text("노선 번호: \(bus.routeno)")
                        Text("노선 ID: \(bus.routeid)")
                        Text("출발 정류장: \(bus.startnodenm)")
                        Text("도착 정류장: \(bus.endnodenm)")
                        Text("출발 시간: \(bus.startvehicletime)")
                        Text("도착 시간: \(bus.endvehicletime)")
                        Text("노선 타입: \(bus.routetp)")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("도시 정보") // 네비게이션 타이틀 설정
    }
}

