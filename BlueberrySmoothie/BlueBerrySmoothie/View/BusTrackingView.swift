// BusTrackingView.swift
// BlueBerrySmoothie

import SwiftUI
import CoreLocation

struct BusTrackingView: View {
    @StateObject private var locationManager = LocationManager.instance
    @StateObject private var busLocationManager = BusLocationManager()
    
    @State private var nearestBus: BusLocation?

    var body: some View {
        VStack {
            if let userLocation = locationManager.location {
                Text("현재 위치: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
                    .font(.caption)
                    .padding()
                
                Button("가장 가까운 버스 찾기") {
                    nearestBus = busLocationManager.findNearestBus(to: userLocation)
                }
                
                if let bus = nearestBus {
                    VStack {
                        Text("가장 가까운 버스 ID: \(bus.busID)")
                            .font(.headline)
                        Text("버스 위치: \(bus.latitude), \(bus.longitude)")
                            .font(.caption)
                        Text("거리: \(calculateDistance(from: userLocation, to: bus)) meters")
                            .font(.caption)
                            .padding(.bottom)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                } else {
                    Text("가장 가까운 버스 정보를 찾을 수 없습니다.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
            } else {
                Text("사용자 위치를 찾는 중...")
                    .font(.caption)
                    .padding()
            }
        }
        .onAppear {
            locationManager.startLocationUpdates()
            updateBusLocations()
        }
        .onDisappear {
            locationManager.stopLocationUpdates()
        }
    }
    
    /// 사용자 위치와 버스 위치 간의 거리를 계산하는 함수
    private func calculateDistance(from userLocation: CLLocation, to bus: BusLocation) -> CLLocationDistance {
        let busLocation = CLLocation(latitude: bus.latitude, longitude: bus.longitude)
        return userLocation.distance(from: busLocation)
    }
    
    /// 버스 위치 정보를 업데이트하는 예시 함수 (API 연동 가능)
    private func updateBusLocations() {
        let sampleBusLocations = [
            BusLocation(busID: "BusA", latitude: 37.5665, longitude: 126.9780),
            BusLocation(busID: "BusB", latitude: 37.5700, longitude: 126.9820),
            BusLocation(busID: "BusC", latitude: 37.5650, longitude: 126.9750)
        ]
        busLocationManager.updateBusLocations(newLocations: sampleBusLocations)
    }
}
