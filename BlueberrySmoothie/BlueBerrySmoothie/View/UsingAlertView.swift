//
//  UsingAlertView 2.swift
//  BlueBerrySmoothie
//
//  Created by 문재윤 on 11/7/24.
//

import SwiftUI

struct UsingAlertView: View {
    @StateObject private var viewModel = NowBusLocationViewModel() // ViewModel 연결
    let busStops: [BusStopLocal] // 정류소 정보 배열
    let busAlert: BusAlert // 관련된 알림 정보
    @State private var isAlertEnabled: Bool = false // 스위치 상태 관리
    @State private var isRefreshing: Bool = false // 새로고침 상태 관리
    @State private var lastRefreshTime: Date? = nil // 마지막 새로고침 시간
    
    // 타이머 설정: 10초마다 자동으로 새로고침
    private let refreshTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    HStack {
                        Text("\(busAlert.busNo)")
                            .foregroundColor(Color.gray3)
                            .font(.regular20)
                        Image(systemName: "suit.diamond.fill")
                            .font(.regular10)
                            .foregroundStyle(.midbrand)
                        Text("\(busAlert.arrivalBusStopNm)")
                            .foregroundColor(Color.gray2)
                            .font(.regular20)
                        Spacer()
//                        VStack {
//                            if let refreshTime = lastRefreshTime {
//                                Text("마지막 새로고침: \(refreshTime, formatter: dateFormatter)")
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                            }
//                            // 새로고침 버튼
//                            Button(action: refreshData) {
//                                Image(systemName: "arrow.clockwise")
//                                    .font(.title3)
//                            }
//                            .disabled(isRefreshing) // 로딩 중에는 비활성화
//                        }
                    }
                    .padding(.bottom, 26)
                    
                    HStack {
                        Text("\(busAlert.alertBusStop)정류장 전 알림")
                            .foregroundStyle(.brand)
                            .font(.regular16)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 26, height: 26)
                                .foregroundColor(Color.gray7)
                            Image(systemName: "bell.fill")
                                .frame(width: 14, height: 14)
                                .foregroundColor(Color.midbrand)
                        }
                        Text("\(busAlert.arrivalBusStopNm)")
//                        Text("\(busAlert.alertBusStopNm)") // n번째 전 정거장 값
                            .foregroundColor(Color.black)
                            .font(.medium30)
                        Spacer()
//                        Toggle(isOn: $isAlertEnabled) { }
//                            .toggleStyle(SwitchToggleStyle(tint: .brand))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top)
                .padding(.bottom, 28)
            }
            .background(Color.lightbrand)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if let closestBus = viewModel.closestBusLocation {
                        ForEach(busStops.filter { $0.routeid == busAlert.routeid }.sorted(by: { $0.nodeord < $1.nodeord }), id: \.id) { busStop in
                            HStack {
                                if busStop.nodeid == closestBus.nodeid {
                                    Image(systemName: "bus.fill")
                                        .foregroundStyle(.brand)
                                        .padding(.leading, 10)
                                } else {
                                    Image(systemName: "bus.fill")
                                        .opacity(0)
                                        .padding(.leading, 10)
                                }
                                VStack {
                                    if busStop.nodeid == busAlert.arrivalBusStopID {
                                        Image(systemName: "mappin.and.ellipse")
                                    } else {
                                        Rectangle()
                                            .frame(width: 1)
                                            .foregroundStyle(.gray5)
                                        ZStack {
                                            Circle()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(Color.gray6)
                                            Circle()
                                                .frame(width: 14, height: 14)
                                                .foregroundColor(Color.lightbrand)
                                            
                                            Image(systemName: "chevron.down")
                                                .foregroundStyle(busStop.nodeid == closestBus.nodeid ? .red : .gray4)
                                                .font(.regular10)
                                                .bold()
                                                .padding(.vertical, 2)
                                        }
                                        Rectangle()
                                            .frame(width: 1)
                                            .foregroundStyle(.gray5)
                                    }
                                }
                                .foregroundStyle(.gray)
                                .padding(.leading, 10)
                                
                                Text(busStop.nodenm) // 정류소 이름 표시
                                    .padding(.leading, 25)
                                    .foregroundColor(Color.black)
                                    .font(.regular16)
                                Spacer()
                            }
                            .frame(height: 60)
                        }
                    } else if isRefreshing {
                        // 로딩 중일 때 로딩 인디케이터 표시
                        ProgressView("가장 가까운 버스 위치를 찾고 있습니다...")
                            .foregroundColor(Color.black)
                            .font(.regular16)
                    } else {
                        Text("가장 가까운 버스 위치를 찾고 있습니다...")
                            .foregroundColor(Color.black)
                            .font(.regular16)
                    }
                    Spacer()
                }
                .background(.clear)
            }
        }
        .background(Color.gray7)
        .navigationTitle("\(busAlert.alertLabel)")
        .navigationBarTitleDisplayMode(.inline)
 
        .onAppear {
            refreshData() // 초기 로드
        }
        
        // 타이머를 활용한 자동 새로고침
        .onReceive(refreshTimer) { _ in
            refreshData()
        }
    }
    
    // 새로고침 함수
    private func refreshData() {
        guard !isRefreshing else { return } // 이미 새로고침 중일 경우 중복 요청 방지
        isRefreshing = true
        DispatchQueue.global(qos: .background).async {
            viewModel.fetchBusLocationData(cityCode: 21, routeId: busAlert.routeid)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                lastRefreshTime = Date() // 새로고침 시간 업데이트
                isRefreshing = false
            }
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}
