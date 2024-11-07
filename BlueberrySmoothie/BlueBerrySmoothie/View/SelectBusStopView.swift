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

    var body: some View {
        VStack {
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

                TextField("정류장 입력", text: $stop)
                    .padding()
                    .frame(height: 40)
                    .frame(maxWidth: .infinity) // Ensures it spans full width
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.brand, lineWidth: 1) // Brand color border, thickness 1
                    )
            }
            .padding(.bottom, 10)

            HStack {
                VStack {
                    if updowncdselection == 2 {
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(bus.endnodenm)방면")
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                            Spacer()
                            Rectangle()
                                .foregroundStyle(.gray2)
                                .frame(height: 1)
                        }
                        .frame(height: 25)
                    } else {
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(bus.endnodenm)방면")
                                Spacer()
                            }
                            Spacer()
                            Rectangle()
                                .foregroundStyle(.midbrand)
                                .frame(height: 2)
                        }
                        .frame(height: 25)
                    }
                }
                .onTapGesture {
                    updowncdselection = 1
                }

                VStack {
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
                        }
                        .frame(height: 25)
                    } else {
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(bus.startnodenm)방면")
                                Spacer()
                            }
                            Spacer()
                            Rectangle()
                                .foregroundStyle(.midbrand)
                                .frame(height: 2)
                        }
                        .frame(height: 25)
                    }
                }
                .onTapGesture {
                    updowncdselection = 2
                }
            }

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    ForEach(busStopViewModel.busStopList, id: \.self) { busstop in
                        Button(action: {
                            storeBusStop(busStop: busstop)
                            dismiss()
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
                        scrollToMiddle(proxy: proxy) // 하행선일 때 중간으로 스크롤
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .navigationTitle("정류장 선택")
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

    // 중간으로 스크롤하는 함수 (하행선 선택 시)
    private func scrollToMiddle(proxy: ScrollViewProxy) {
        // 목록의 중간 위치에 해당하는 정류장을 찾아서 스크롤
        let middleIndex = busStopViewModel.busStopList.count / 2
        let middleStop = busStopViewModel.busStopList[middleIndex]

        // 해당 정류장으로 스크롤
        proxy.scrollTo(middleStop.nodeid, anchor: .center)
    }

    func storeBusStop(busStop: BusStop) {
        // 상행의 가장 큰 order 구함
        if let maxUpwardNodeord = busStopViewModel.busStopList.filter({ $0.updowncd == 0 }).map({ $0.nodeord }).max() {
            // 기본 busStopAlert 데이터 저장
            busStopAlert = BusStopAlert(cityCode: Double(city.citycode), bus: bus, allBusStop: busStopViewModel.busStopList, arrivalBusStop: busStop, alertBusStop: 0)

            // 이전 정류장 (1~3번째) 저장
            if var unwrappedBusStopAlert = busStopAlert {
                storeBeforeBusStops(for: busStop, alert: &unwrappedBusStopAlert, busStops: busStopViewModel.busStopList, maxUpwardNodeord: maxUpwardNodeord)
                busStopAlert = unwrappedBusStopAlert
            }
        }
    }

    private func storeBeforeBusStops(for busStop: BusStop, alert: inout BusStopAlert, busStops: [BusStop], maxUpwardNodeord: Int) {
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

        // 일반적인 경우엔 위의 과정을 거쳐와도 currentIndex가 3보다 작지 않기 때문에 아무 상관 없음
        // 이전 정류장을 최대 3개까지 저장함
        alert.firstBeforeBusStop = currentIndex > 1 ? busStops[busStop.nodeord - 2] : nil
        alert.secondBeforeBusStop = currentIndex > 2 ? busStops[busStop.nodeord - 3] : nil
        alert.thirdBeforeBusStop = currentIndex > 3 ? busStops[busStop.nodeord - 4] : nil
    }
} 
