////
////  SelectBusView.swift
////  BlueberrySmoothie
////
////  Created by 문재윤 on 10/31/24.
////
//
//import SwiftUI
//
//// 도시 정보를 선택하는 뷰
//struct SelectBusView: View {
//    let city: City // 도시 정보
//    @State private var buses: [Bus] = [] // 버스 목록을 저장하는 상태 변수
//    @State private var routeNo: String = "" // 입력된 노선 번호를 저장하는 상태 변수
//    @FocusState private var isTextFieldFocused: Bool
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                HStack{
//                    TextField("버스 번호 입력", text: $routeNo) // 노선 번호 입력 필드
//                        .font(.system(size: 25))
//                        .textFieldStyle(.plain)
//                        .focused($isTextFieldFocused)
//                        .keyboardType(.numberPad)
//                        .onChange(of: routeNo) { newRouteNo in
//                            fetchBusData(citycode: city.citycode, routeNo: newRouteNo) { fetchedBuses in
//                                self.buses = fetchedBuses.sorted {
//                                    // 글자 수가 적은 것 우선
//                                    let firstLength = $0.routeno.count
//                                    let secondLength = $1.routeno.count
//                                    if firstLength == secondLength {
//                                        // 글자 수가 같으면 노선 번호로 정렬
//                                        return $0.routeno < $1.routeno
//                                    }
//                                    return firstLength < secondLength
//                                }
//                                print(fetchedBuses)
//                            }
//                        }
//                    Image(systemName: "magnifyingglass")
//                        .foregroundColor(isTextFieldFocused ? .blue : .gray2)
//                }
//                .padding(.horizontal, 36)
//                .padding(.bottom, -8)
//                .padding(.top, 30)
//                
//                
//                Rectangle()
//                    .foregroundColor(isTextFieldFocused ? .blue : .gray2)
//                    .frame(height: 2)
//                    .padding(.horizontal,20)
//                
//                ScrollView(showsIndicators: false) {
//                    ForEach(buses) { bus in // 버스 목록을 ForEach로 표시
//                        NavigationLink(destination: BusDetailView(bus: bus))  {
//                            VStack(alignment: .leading) {
//                                Spacer()
//                                VStack(alignment: .leading) {
//                                    Text("\(bus.routeno)")
//                                        .font(.system(size: 20))
//                                        .foregroundColor(bus.routetp == "일반버스" || bus.routetp == "간선버스" ? .blue : bus.routetp == "마을버스" || bus.routetp == "지선버스" ? .green : bus.routetp == "급행버스" || bus.routetp == "광역버스" ? .red : bus.routetp == "순환버스" ? .yellow : .primary ) // 조건에 따라 색상 설정
//                                    HStack{
//                                        Text("\(bus.startnodenm) - \(bus.endnodenm)")
//                                            .foregroundStyle(.gray)
//                                    }
//                                }
//                                .padding(.horizontal, 16)
//                                Spacer()
//                                
//                                Divider()
//                                    .padding(.top, 16)
//                                    .padding(.bottom, 20)
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//            }
//            .onTapGesture {
//                isTextFieldFocused = false // 다른 곳 클릭 시 키보드 숨김
//            }
//            .navigationTitle("버스 검색") // 네비게이션 타이틀 설정
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}


import SwiftUI





struct SelectBusView: View {
    let city: City // 도시 정보
    @State private var allBuses: [Bus] = [] // 전체 버스 목록
    @State private var filteredBuses: [Bus] = [] // 필터링된 버스 목록
    @State private var routeNo: String = "" // 입력된 노선 번호를 저장하는 상태 변수
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    TextField("버스 번호 입력", text: $routeNo) // 노선 번호 입력 필드
                        .font(.system(size: 25))
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)
                        .keyboardType(.numberPad)
                        .onChange(of: routeNo) { newRouteNo in
                            filteredBuses = filterBuses(by: newRouteNo, from: allBuses) // 노선 번호에 따라 필터링
                        }
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(isTextFieldFocused ? .blue : .gray2)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, -8)
                .padding(.top, 30)
                
                Rectangle()
                    .foregroundColor(isTextFieldFocused ? .blue : .gray2)
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    ForEach(filteredBuses) { bus in // 필터링된 버스 목록을 ForEach로 표시
                        NavigationLink(destination: BusDetailView(bus: bus)) {
                            VStack(alignment: .leading) {
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(bus.routeno)")
                                        .font(.system(size: 20))
                                        .foregroundColor(busColor(for: bus.routetp))
                                    HStack {
                                        Text("\(bus.startnodenm) - \(bus.endnodenm)")
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .padding(.horizontal, 16)
                                Spacer()
                                
                                Divider()
                                    .padding(.top, 16)
                                    .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .onTapGesture {
                isTextFieldFocused = false // 다른 곳 클릭 시 키보드 숨김
            }
            .navigationTitle("버스 검색") // 네비게이션 타이틀 설정
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchAllBusData(citycode: city.citycode) { fetchedBuses in
                    self.allBuses = fetchedBuses
                    self.filteredBuses = fetchedBuses // 초기 필터링된 버스 목록 설정

                }
            }
        }
    }
}

struct SelectBusView_Previews: PreviewProvider {
    static var previews: some View {
        SelectBusView(city: City(citycode: 21, cityname: "부산"))
    }
}
