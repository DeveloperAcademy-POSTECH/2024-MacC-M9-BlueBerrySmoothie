//
//  kkView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/6/24.
//

import SwiftUI
import SwiftData

struct SelectBusStopView: View {
    //    let city: City // 도시 정보
    let bus: Bus // 선택된 버스 정보
    let cityCode: Int // ← 추가된 부분
    @Binding var busStopAlert: BusStopAlert?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var busStopViewModel: BusStopViewModel
    @State private var stop: String = ""
    @State private var updowncdselection: Int = 1
    @Binding var showSelectBusSheet: Bool
    
    var body: some View {
        VStack{
            HStack {
                Text("\(bus.routeno)")
                    .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 0))
                Spacer()
                Image("magnifyingglass")
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.gray3)
                    .padding(.trailing, 20.67)
            }
            .background(.gray6)
            .cornerRadius(20)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray5, lineWidth: 1)
            }
            .padding(EdgeInsets(top: 44, leading: 0, bottom: 24, trailing: 0))
            
            HStack {
                directionView(
                    directionName: "\(bus.endnodenm)방면",
                    isSelected: updowncdselection == 1,
                    selectedColor: .midbrand,
                    unselectedColor: .gray2
                )
                .onTapGesture {
                    updowncdselection = 1
                }
                
                directionView(
                    directionName: "\(bus.startnodenm)방면",
                    isSelected: updowncdselection == 2,
                    selectedColor: .midbrand,
                    unselectedColor: .gray2
                )
                .onTapGesture {
                    updowncdselection = 2
                }
            }
            //BusStop 리스트 View
            BusStopScrollView()
        }
        .padding(.horizontal, 20)
        .navigationTitle("버스 검색")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 닫기 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body) // TODO: body1로 수정
                        Text("뒤로")
                            .font(.body) //TODO: body2로 수정
                            .padding(.leading, -7)
                    }
                    .foregroundStyle(.gray1)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await busStopViewModel.getBusStopData(cityCode: cityCode, routeId: bus.routeid)
        }
    }
    
    /// Bus List 뷰
    private func BusStopScrollView() -> some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                ForEach(busStopViewModel.busStopList, id: \.nodeord) { busstop in
                    Button(action: {
                        storeBusStop(busStop: busstop)
                        showSelectBusSheet = false
                    }) {
                        VStack {
                            Spacer()
                            HStack {
                                Text("\(busstop.nodenm)")
                                    .padding(.leading, 24)
                                    .foregroundStyle(.black)
                                Text("\(busstop.nodeid)")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.gray)
                                
                                Spacer()
                            }
                            Spacer()
                            Divider()
                        }
                        .frame(height: 60)
                    }
                    .id(busstop.nodeid) // 각 정류장에 고유 ID를 설정
                }
            }
            .onChange(of: updowncdselection) { _ in
                if updowncdselection == 1 {
                    scrollToTop(proxy: proxy)
                } else {
                    scrollToMiddle(proxy: proxy)
                }
            }
        }
    }
    
    // 최상단으로 스크롤하는 함수
    private func scrollToTop(proxy: ScrollViewProxy) {
        if let firstStop = busStopViewModel.busStopList.first {
            proxy.scrollTo(firstStop.nodeid, anchor: .top)
        }
    }
    
    // 하행의 첫 인덱스로 스크롤하는 함수
    private func scrollToMiddle(proxy: ScrollViewProxy) {
        // 하행의 가장 작은 order 구함
        if let maxUpwardNodeord = busStopViewModel.busStopList.filter({ $0.updowncd == 1 }).map({ $0.nodeord }).min() {
            //해당 order로 스크롤을 이동함
            proxy.scrollTo(maxUpwardNodeord, anchor: .center)
        }
    }
    
    // 최하단으로 스크롤하는 함수
    //    private func scrollToBottom(proxy: ScrollViewProxy) {
    //        if let firstStop = busStopViewModel.busStopList.last {
    //            proxy.scrollTo(firstStop.nodeid, anchor: .bottom)
    //        }
    //    }
    
    // 버스 정류장 데이터 저장
    func storeBusStop(busStop: BusStop){
        // 기본 busStopAlert 데이터 저장
        busStopAlert = BusStopAlert(cityCode: Double(cityCode), bus: bus, allBusStop: busStopViewModel.busStopList, arrivalBusStop: busStop, alertBusStop: 0)
        
        // 이전 정류장 (1~3번째) 저장
        if var unwrappedBusStopAlert = busStopAlert {
            storeBeforeBusStops(for: busStop, alert: &unwrappedBusStopAlert, busStops: busStopViewModel.busStopList)
            busStopAlert = unwrappedBusStopAlert
        }
    }
    
    private func directionView(directionName: String, isSelected: Bool, selectedColor: Color, unselectedColor: Color) -> some View {
        VStack {
            HStack {
                Spacer()
                Text(directionName)
                    .foregroundColor(isSelected ? .primary : .gray)
                Spacer()
            }
            Spacer()
            Rectangle()
                .foregroundStyle(isSelected ? selectedColor : unselectedColor)
                .frame(height: isSelected ? 2 : 1)
        }
        .frame(height: 25)
    }
    
    // 차고지 - 회차지가 있는 일반적인 경우를 예외 처리하여 이전 3 정류장을 저장한다
    private func storeBeforeBusStops(for busStop: BusStop, alert: inout BusStopAlert, busStops: [BusStop]) {
        let currentIndex: Int = busStop.nodeord// 선택한 정류장 이전의 정류장이 몇 개 남아있는지 확인하는 용도
        
        // 이전 정류장을 최대 3개까지 저장함
        // nodeord가 1부터 시작해서 n+1 만큼 빼주어야함
        alert.firstBeforeBusStop = currentIndex > 1 ? busStops[busStop.nodeord - 2] : nil
        alert.secondBeforeBusStop = currentIndex > 2 ? busStops[busStop.nodeord - 3] : nil
        alert.thirdBeforeBusStop = currentIndex > 3 ? busStops[busStop.nodeord - 4] : nil
    }
}

