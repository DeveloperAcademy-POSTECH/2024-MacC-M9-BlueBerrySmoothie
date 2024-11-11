//
//  NowBusLocationViewModel.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 11/11/24.
//


import Foundation
import SwiftUI
import CoreLocation
import Combine

class NowBusLocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var NowbusLocations: [NowBusLocation] = []
    @Published var closestBusLocation: NowBusLocation?

    private var cancellables = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        fetchBusLocationData(cityCode: 21, routeId: "BSB5200043000")
    }

    // CLLocationManagerDelegate 메서드 - 사용자 위치 업데이트 시 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        findClosestBusLocation()
    }

    // API를 호출하여 버스 위치 데이터를 가져옴
    func fetchBusLocationData(cityCode: Int, routeId: String) {
        fetchNowBusLocationData(cityCode: cityCode, routeId: routeId) { [weak self] locations in
            DispatchQueue.main.async {
                self?.NowbusLocations = locations
                self?.findClosestBusLocation() // 데이터 가져온 후 가장 가까운 버스 위치 계산
            }
        }
    }

    // 사용자 위치와 가장 가까운 버스 위치를 찾음
    private func findClosestBusLocation() {
        guard let userLocation = userLocation else { return }

        closestBusLocation = NowbusLocations.min(by: { bus1, bus2 in
            let busLocation1 = CLLocation(latitude: Double(bus1.gpslati) ?? 0, longitude: Double(bus1.gpslong) ?? 0)
            let busLocation2 = CLLocation(latitude: Double(bus2.gpslati) ?? 0, longitude: Double(bus2.gpslong) ?? 0)

            return userLocation.distance(from: busLocation1) < userLocation.distance(from: busLocation2)
        })
    }
}




