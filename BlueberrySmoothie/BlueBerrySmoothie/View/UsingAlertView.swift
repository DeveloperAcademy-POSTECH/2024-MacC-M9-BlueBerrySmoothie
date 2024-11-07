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
                VStack { }
                VStack {
                    HStack {
                        Text("\(busAlert.busNo)")
                        Image(systemName: "suit.diamond.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.midbrand)
                        Text("\(busAlert.alertLabel)")
                        Spacer()
                        VStack {
                            if let refreshTime = lastRefreshTime {
                                Text("마지막 새로고침: \(refreshTime, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            // 새로고침 버튼
                            Button(action: refreshData) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                            }
                            .disabled(isRefreshing) // 로딩 중에는 비활성화
                        }
                    }
                    .font(.title3)
                    .foregroundStyle(.gray2)
                    
                    HStack {
                        Text("\(busAlert.alertBusStop)정류장 전 알림")
                            .foregroundStyle(.gray3)
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "bell.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(.midbrand)
                        Text("\(busAlert.arrivalBusStopNm)")
                        Toggle(isOn: $isAlertEnabled) { }
                            .toggleStyle(SwitchToggleStyle(tint: .brand))
                    }
                    .font(.title)
                }
                .padding(.horizontal, 20)
                .padding(.top)
                .padding(.bottom, 28)
            }
            .background(Color.white)
            
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
                                        Image(systemName: "circle.fill")
                                            .foregroundStyle(busStop.nodeid == closestBus.nodeid ? .red : .brand)
                                            .font(.system(size: 5))
                                            .padding(.vertical, 2)
                                        Rectangle()
                                            .frame(width: 1)
                                            .foregroundStyle(.gray5)
                                    }
                                }
                                .foregroundStyle(.gray)
                                .padding(.leading, 10)
                                
                                Text(busStop.nodenm) // 정류소 이름 표시
                                    .padding(.leading, 25)
                                    .font(.system(size: 16))
                                Spacer()
                            }
                            .frame(height: 60)
                        }
                    } else if isRefreshing {
                        // 로딩 중일 때 로딩 인디케이터 표시
                        ProgressView("가장 가까운 버스 위치를 찾고 있습니다...")
                    } else {
                        Text("가장 가까운 버스 위치를 찾고 있습니다...")
                    }
                    Spacer()
                }
            }
        }
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
