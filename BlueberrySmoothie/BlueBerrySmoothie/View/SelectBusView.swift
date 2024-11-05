
import SwiftUI

struct SelectBusView: View {
    @Binding var selectedBus: Bus? // 선택된 버스를 전달하는 바인딩
    @Binding var selectedBusStop: BusStop?
    @Binding var allBusStops: [BusStop]
    
    let city: City = City(citycode: 21, cityname: "부산")
    @State private var allBuses: [Bus] = []
    @State private var filteredBuses: [Bus] = []
    @State private var routeNo: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // 선택된 버스에 따라 SelectBusStopView로 네비게이션하기 위한 상태
    @State private var navigateToBusStopView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    TextField("버스 번호 입력", text: $routeNo)
                        .font(.system(size: 25))
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)
                        .keyboardType(.numberPad)
                        .onChange(of: routeNo) { newRouteNo in
                            filteredBuses = filterBuses(by: newRouteNo, from: allBuses)
                        }
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(isTextFieldFocused ? .blue : .gray)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, -8)
                .padding(.top, 30)
                
                Rectangle()
                    .foregroundColor(isTextFieldFocused ? .blue : .gray)
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    ForEach(filteredBuses) { bus in
                        Button(action: {
                            // 선택된 버스를 설정하고 네비게이션 활성화
                            selectedBus = bus
                            navigateToBusStopView = true
                        }) {
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
                
             
                // 네비게이션 링크: 선택된 버스가 있을 때 SelectBusStopView로 이동
                NavigationLink(
                       destination: Group {
                           if let bus = selectedBus { // 안전하게 선택된 버스를 확인
                               SelectBusStopView(city: city, bus: bus, selectedBusStop: $selectedBusStop, allBusStops: $allBusStops)
                           }
                       },
                       isActive: $navigateToBusStopView
                   ) {
                       EmptyView()
                   }
                   .hidden() // 빈 뷰로 숨기기
                           }
            .onTapGesture {
                isTextFieldFocused = false // 다른 곳 클릭 시 키보드 숨김
            }
            .navigationTitle("버스 검색")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchAllBusData(citycode: city.citycode) { fetchedBuses in
                    self.allBuses = fetchedBuses
                    self.filteredBuses = fetchedBuses
                }
            }
        }
    }
    
    private func filterBuses(by routeNo: String, from buses: [Bus]) -> [Bus] {
        return buses.filter { $0.routeno.contains(routeNo) }
    }
}
