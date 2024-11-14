//
//  kkView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/6/24.
//

import SwiftUI
import SwiftData

struct SelectBusStopView: View {
    let city: City // 도시 정보
    let bus: Bus // 선택된 버스 정보
    @Binding var busStopAlert: BusStopAlert?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var busStopViewModel: BusStopViewModel
    @State private var stop: String = ""
    @State private var updowncdselection: Int = 1
    @Binding var showSelectBusSheet: Bool
    
    var body: some View {
        VStack{
            VStack {
                HStack {
                    Text("\(bus.routeno)")
                        .padding(.leading, 15)
                    Spacer()
                }
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray6) // RoundedRectangle에만 배경 색을 적용
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray6, lineWidth: 1)
                )
                .frame(maxWidth: .infinity) // Match width to TextField's width
                .padding(.bottom, 12)
            }
            .padding(.bottom, 10)
            
            // TODO: 방면 2와 1이 같은 코드를 사용하고 있기 때문에 따로 분리하기
            HStack {
                VStack{
                    if updowncdselection == 2 {
                        VStack {
                            HStack{
                                Spacer()
                                Text("\(bus.endnodenm)방면")
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                            Spacer()
                            Rectangle()
                                .foregroundStyle(.gray2)
                                .frame(height: 1)
                        }.frame(height: 25)
                    } else {
                        VStack {
                            HStack{
                                Spacer()
                                Text("\(bus.endnodenm)방면")
                                
                                Spacer()
                            }
                            Spacer()
                            Rectangle()
                                .foregroundStyle(.midbrand)
                                .frame(height: 2)
                        }.frame(height: 25)
                    }
                }
                .onTapGesture {
                    updowncdselection = 1
                }
                
                VStack() {
                    if updowncdselection == 1 {
                        VStack {
                            HStack(alignment: .bottom) {
                                Spacer()
                                Text("\(bus.startnodenm)방면")
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                            Spacer()
                            Rectangle()
                                .foregroundStyle(.gray2)
                                .frame(height: 1)
                        }.frame(height: 25)
                    } else {
                        VStack {
                            HStack{
                                Spacer()
                                Text("\(bus.startnodenm)방면")
                                Spacer()
                            }
                            Spacer()
                            Rectangle()
                                .foregroundStyle(.midbrand)
                                .frame(height: 2)
                        }.frame(height: 25)
                    }
                }
                .onTapGesture {
                    updowncdselection = 2
                }
                
            }
            
            // TODO: BusStopList로 분리
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
        .padding(.horizontal, 20)
        .navigationTitle("정류장 선택")
        .toolbar { // ← 모달 닫기 버튼 추가
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("닫기") {
                    showSelectBusSheet = false
                }
            }
        }
        .task {
            await busStopViewModel.getBusStopData(cityCode: city.citycode, routeId: bus.routeid)
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
            proxy.scrollTo(40, anchor: .center)
        }
    }
    // 최하단으로 스크롤하는 함수
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let firstStop = busStopViewModel.busStopList.last {
            proxy.scrollTo(firstStop.nodeid, anchor: .bottom)
        }
    }
    
    // 버스 정류장 데이터 저장
    func storeBusStop(busStop: BusStop){
        // 기본 busStopAlert 데이터 저장
        busStopAlert = BusStopAlert(cityCode: Double(city.citycode), bus: bus, allBusStop: busStopViewModel.busStopList, arrivalBusStop: busStop, alertBusStop: 0)
        
        // 이전 정류장 (1~3번째) 저장
        if var unwrappedBusStopAlert = busStopAlert {
            storeBeforeBusStops(for: busStop, alert: &unwrappedBusStopAlert, busStops: busStopViewModel.busStopList)
            busStopAlert = unwrappedBusStopAlert
        }
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

