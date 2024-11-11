
import SwiftUI

struct SelectBusView: View {
    @Binding var busStopAlert: BusStopAlert?
    
    
    let city: City = City(citycode: 21, cityname: "부산")
    @State private var allBuses: [Bus] = []
    @State private var filteredBuses: [Bus] = []
    @State private var routeNo: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @Binding var showSelectBusSheet: Bool

    
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
                        .foregroundColor(isTextFieldFocused ? .brand : .gray)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, -8)
                .padding(.top, 30)
                
                Rectangle()
                    .foregroundColor(isTextFieldFocused ? .brand : .gray)
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    ForEach(filteredBuses) { bus in
                        Button(action: {
                            // 선택된 버스를 설정하고 네비게이션 활성화
                            busStopAlert?.bus = bus
                            
                        }) {
                            // 네비게이션 링크: 선택된 버스가 있을 때 SelectBusStopView로 이동
                            NavigationLink(destination: SelectBusStopView(city: city, bus: bus, busStopAlert: $busStopAlert, showSelectBusSheet: $showSelectBusSheet)){
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
                }
                .padding(.horizontal, 20)
                
            }
            .onTapGesture {
                isTextFieldFocused = false // 다른 곳 클릭 시 키보드 숨김
            }
            .navigationTitle("버스 검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                // 닫기 버튼
                   ToolbarItem(placement: .navigationBarLeading) {
                       Button(action: {
                           dismiss()  // 현재 화면을 닫는 동작
                       }) {
                           Text("닫기")
                               .font(.regular16)
                               .foregroundColor(Color.brand) // 원하는 색상으로 변경 가능
                       }
                   }
            }
            .onAppear {
                fetchAllBusData(citycode: city.citycode) { fetchedBuses in
                    self.allBuses = fetchedBuses
                    self.filteredBuses = fetchedBuses
                }
                showSelectBusSheet = true
            }
        }
    }
    
    private func filterBuses(by routeNo: String, from buses: [Bus]) -> [Bus] {
        return buses.filter { $0.routeno.contains(routeNo) }
    }
}
