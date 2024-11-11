//
//  BellaBellaView.swift
//  BlueBerrySmoothie
//
//  Created by 이진경 on 11/6/24.
//

import SwiftUI

struct BellaBellaGPS {
    var name: String
    var lati: Double
    var long: Double
    
}


struct BellaBellaView: View {
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    BellaBellaView()
}
//import SwiftUI
//import CoreLocation
//
//// 1. LocationManager 정의
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private var locationManager = CLLocationManager()
//
//    @Published var userLocation: CLLocation? // 현재 위치 정보
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        userLocation = location
//    }
//}
//
//struct BusStopListView: View {
//    @ObservedObject var locationManager = LocationManager() // LocationManager 인스턴스
//    let busStops: [BusStopLocal] // 정류소 정보 배열
//    let alert: Alert // 알림 정보
//    @State private var isAlertEnabled: Bool = false // 알림 스위치 상태
//    @State private var nearestBusStop: BusStopLocal? // 가장 가까운 정류장 정보
//
//    var body: some View {
//        VStack {
//            // 알림 설정 UI
//            VStack {
//                HStack {
//                    Text("\(alert.busNo)")
//                    Image(systemName: "suit.diamond.fill")
//                        .font(.system(size: 10))
//                        .foregroundStyle(.midbrand)
//                    Text("\(alert.alertLabel)")
//                    Spacer()
//                }
//                .font(.title3)
//                .foregroundStyle(.gray2)
//                HStack {
//                    Image(systemName: "bell.circle")
//                        .font(.system(size: 20))
//                        .foregroundStyle(.midbrand)
//                    Text("운촌")
//                    Toggle(isOn: $isAlertEnabled) { }
//                        .toggleStyle(SwitchToggleStyle(tint: .brand))
//                }
//                .font(.title)
//                HStack {
//                    Text("12정류장 후 알림")
//                        .foregroundStyle(.gray3)
//                    Spacer()
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top)
//            .padding(.bottom, 28)
//            .background(.white)
//
//            // 정류장 목록 UI
//            ScrollView(showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 0) {
//                    ForEach(busStops, id: \.id) { busStop in
//                        HStack {
//                            VStack {
//                                Rectangle()
//                                    .frame(width: 1)
//                                    .foregroundStyle(.gray5)
//                                Image(systemName: "circle.fill")
//                                    .foregroundStyle(.brand)
//                                    .font(.system(size: 5))
//                                    .padding(.vertical, 2)
//                                Rectangle()
//                                    .frame(width: 1)
//                                    .foregroundStyle(.gray5)
//                            }
//                            .padding(.leading, 40)
//
//                            Text(busStop.nodenm)
//                                .padding(.leading, 25)
//                                .font(.system(size: 16))
//                            Spacer()
//                        }
//                        .frame(height: 60)
//                    }
//                    Spacer()
//                }
//            }
//        }
//        .navigationTitle("출근하기")
//        .background(.doublelightbrand)
//        .onAppear {
//            updateNearestBusStop()
//        }
//        .onChange(of: locationManager.userLocation) { _ in
//            updateNearestBusStop()
//        }
//    }
//
//    // 3. 가장 가까운 정류장 업데이트
//    func updateNearestBusStop() {
//        guard let userLocation = locationManager.userLocation else { return }
//        nearestBusStop = busStops.min(by: { busStop1, busStop2 in
//            let location1 = CLLocation(latitude: busStop1.gpslati, longitude: busStop1.gpslong)
//            let location2 = CLLocation(latitude: busStop2.gpslati, longitude: busStop2.gpslong)
//            return userLocation.distance(from: location1) < userLocation.distance(from: location2)
//        })
//
//        // 사용자가 선택한 정류장과 가까운 경우 알림 트리거
//        if isAlertEnabled, let nearestBusStop = nearestBusStop, nearestBusStop.nodeid == alert.arrivalBusStopID {
//            triggerAlert()
//        }
//    }
//
//    // 4. 알림 트리거 함수
//    func triggerAlert() {
//        // 알림을 트리거할 때 필요한 작업 수행
//        print("정류장 도착 알림!")
//    }
//}
