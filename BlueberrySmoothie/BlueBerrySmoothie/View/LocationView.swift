//
//  LocationView.swift
//  MapkitTest
//
//  Created by 문호 on 10/24/24.
//

import SwiftUI
import CoreLocation
import MapKit


struct LocationView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(spacing: 20) {
            if let errorMessage = locationManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("현재 주소")
                        .font(.headline)
                    
                    // 상세 주소 정보 표시
                    if !locationManager.detailedAddress.administrativeArea.isEmpty {
                        Text("시/도: \(locationManager.detailedAddress.administrativeArea)")
                            .font(.subheadline)
                    }
                    if !locationManager.detailedAddress.locality.isEmpty {
                        Text("시/군/구: \(locationManager.detailedAddress.locality)")
                            .font(.subheadline)
                    }
                    if !locationManager.detailedAddress.subLocality.isEmpty {
                        Text("동/읍/면: \(locationManager.detailedAddress.subLocality)")
                            .font(.subheadline)
                    }
                    if !locationManager.detailedAddress.thoroughfare.isEmpty {
                        Text("도로명: \(locationManager.detailedAddress.thoroughfare)")
                            .font(.subheadline)
                    }
                    if !locationManager.detailedAddress.subThoroughfare.isEmpty {
                        Text("건물번호: \(locationManager.detailedAddress.subThoroughfare)")
                            .font(.subheadline)
                    }
                    
                    if let location = locationManager.location {
                        Text("위도: \(location.coordinate.latitude)")
                            .font(.subheadline)
                        Text("경도: \(location.coordinate.longitude)")
                            .font(.subheadline)
                    }
                    
                    Text("마지막 새로고침: \(formatDate(locationManager.lastRefreshTime))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()
                
                Button(action: {
                    locationManager.refreshLocation()
                }) {
                    Text("수동 새로고침")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .navigationTitle("내 위치")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

#Preview {
    LocationView()
}
