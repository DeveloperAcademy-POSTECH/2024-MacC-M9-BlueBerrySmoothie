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
    @State private var updowncdselection: Int = 1 // 상행 하행 구분
    @State private var isAutoScroll: Bool = false // 상행 하행 버튼과 스크롤로 이동될 때의 action이 중복되지 않도록 방지하는 변수
    @Binding var showSelectBusSheet: Bool
    @State private var isAnimating = false // 버스 리스트가 아래에서 위로 올라오는 애니메이션 실행 여부
    
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
            
            VStack {
                HStack {
                    directionView(
                        directionName: "\(bus.endnodenm)방면", // 상행
                        isSelected: updowncdselection == 1,
                        selectedColor: .brand,
                        unselectedColor: .gray2
                    )
                    .onTapGesture {
                        updowncdselection = 1
                        isAutoScroll = true // 버튼을 누르면 자동으로 해당 위치로 스크롤 되도록함
                    }
                    
                    directionView(
                        directionName: "\(bus.startnodenm)방면", // 하행
                        isSelected: updowncdselection == 2,
                        selectedColor: .brand,
                        unselectedColor: .gray2
                    )
                    .onTapGesture {
                        updowncdselection = 2
                        isAutoScroll = true // 버튼을 누르면 자동으로 해당 위치로 스크롤 되도록함
                    }
                }
                //BusStop 리스트 View
                BusStopScrollView()
            }
            // 버스 리스트가 아래에서 위로 올라오는 애니메이션 위치
            .offset(y: isAnimating ? 0 : UIScreen.main.bounds.height)
        }
        // 버스 리스트가 아래에서 위로 올라오는 애니메이션
        .animation(.spring(duration: 1.0, bounce: 0.1), value: isAnimating)
        .onAppear {
            isAnimating = true
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
                            .font(.body1)
                        Text("뒤로")
                            .font(.body2)
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
                                
                                Spacer()
                            }
                            Spacer()
                            Divider() // 상행의 마지막 item의 divider의 색과 굵기 변경
                                .frame(height: busstop.nodeord == busStopViewModel.maxUpwardNodeord! ? 2 : 1)
                                .background(busstop.nodeord == busStopViewModel.maxUpwardNodeord! ? .midbrand : .gray5)
                                .overlay(
                                    // 상행의 마지막 item을 스크롤 할 때 상단의 방면이 자동으로 변경되도록 함
                                    busstop.nodeord == busStopViewModel.maxUpwardNodeord! ? GeometryReader { proxy in
                                        Color.clear
                                            .onChange(of: proxy.frame(in: .global).midY) {_, midY in
                                                handleScrollChange(midY: midY)
                                            }
                                    } : nil
                                )
                        }
                        .frame(height: 60)
                    }
                    .id(busstop.nodeid) // 각 정류장에 고유 ID를 설정
                }
            }
            .onChange(of: updowncdselection) { _, _ in
                // 상행, 하행 버튼을 눌렀을 경우에만 자동 스크롤이 되도록 함
                if isAutoScroll {
                    if updowncdselection == 1 {
                        scrollToTop(proxy: proxy)
                    } else {
                        scrollToMiddle(proxy: proxy)
                    }
                    isAutoScroll = false // 실행 후 자동 스크롤 변수 초기화
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
        if let minDownwardNodeord = busStopViewModel.busStopList.filter({ $0.updowncd == 1 }).map({ $0.nodeord }).min() {
            //해당 order로 스크롤을 이동함
            proxy.scrollTo(minDownwardNodeord, anchor: .center)
        }
    }
    
    private func handleScrollChange(midY: CGFloat) {
        let screenHeight = UIScreen.main.bounds.height
        let centerY = screenHeight / 3 * 2
        
        if midY > centerY && updowncdselection != 1 {
            updowncdselection = 1 // 중앙 아래
            HapticManager.shared.triggerImpactFeedback(style: .light)
        } else {
            if midY < centerY && updowncdselection != 2 { // updowncdselection의 상태가 변경될 때만 실행,
                updowncdselection = 2 // 중앙 위
                HapticManager.shared.triggerImpactFeedback(style: .light)
            }
        }
    }
    
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

