
import SwiftUI

struct SelectBusView: View {
    let cityCode: Int
    @Binding var busStopAlert: BusStopAlert?
    @State private var allBuses: [Bus] = []
    @State private var filteredBuses: [Bus] = [] // 버스 번호 검색에 사용
    @State private var routeNo: String = ""
    @FocusState private var isTextFieldFocused: Bool // 검색란 활성화 여부 체크
    @Environment(\.dismiss) private var dismiss
    @Binding var showSelectBusSheet: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.whiteDgray1)
                    .onTapGesture {
                        isTextFieldFocused = false // 다른 곳 클릭 시 키보드 숨김
                    }
                VStack(spacing: 20) {
                    HStack(alignment: .center) {
                        TextField("버스 번호", text: $routeNo)
                            .font(.body1)
                            .foregroundStyle(.blackDGray7)
                            .textFieldStyle(.plain)
                            .focused($isTextFieldFocused)
                            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 0))
                            .keyboardType(.numberPad)
                            .onChange(of: routeNo) { _, newRouteNo in
                                filteredBuses = filterBuses(by: newRouteNo, from: allBuses)
                            }
                            .tint(.brand)
                        Spacer()
                        Image("magnifyingglass")
                            .frame(width: 24, height: 24)
                            .padding(.trailing, 20.67)
                        
                    }
                    .background(.gray6Dgray2)
                    .cornerRadius(20)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isTextFieldFocused == true ? .brand : .gray5Dgray3, lineWidth: 1)
                    }
                    .padding(EdgeInsets(top: 44, leading: 20, bottom: 8, trailing: 20))
                    // 버스 리스트
                    busListScrollView()
                }
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
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.body1)
                            Text("뒤로")
                                .font(.body2)
                                .padding(.leading, -7)
                        }
                        .foregroundStyle(.gray1DBrand)
                    }
                }
            }
            .onAppear {
                fetchAllBusData(citycode: cityCode) { fetchedBuses in
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
    
    private func busListScrollView() -> some View {
        ScrollView(showsIndicators: false) {
            ForEach(filteredBuses) { bus in
                Button(action: {
                    // 선택된 버스를 설정하고 네비게이션 활성화
                    busStopAlert?.bus = bus
                }) {
                    // 네비게이션 링크: 선택된 버스가 있을 때 SelectBusStopView로 이동
                    NavigationLink(destination: SelectBusStopView(bus: bus, cityCode: cityCode, busStopAlert: $busStopAlert, showSelectBusSheet: $showSelectBusSheet)){
                        VStack(alignment: .leading) {
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("\(bus.routeno)")
                                    .font(.body)
                                    .foregroundStyle(.brand)
                                    .padding(.bottom, 4)
                                HStack {
                                    Text("\(bus.startnodenm) - \(bus.endnodenm)")
                                        .font(.caption2)
                                        .foregroundStyle(.gray3Dgray6)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            Divider()
                                .padding(.top, 20)
                                .padding(.bottom, 16)
                        }
                    }
                }
                
            }
        }
        .padding(.horizontal, 20)
    }
}
