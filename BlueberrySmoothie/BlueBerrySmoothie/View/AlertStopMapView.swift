//
//  MapTestDaisy.swift
//  BlueBerrySmoothie
//
//  Created by 원주연 on 11/16/24.
//

import SwiftUI
import MapKit

struct BusStopLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

struct AlertStopMapView: View {
    let busStop: BusStopLocal
    @StateObject private var locationManager = LocationManager.shared
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    
    // 지도의 초기 영역 설정
    @State private var region: MKCoordinateRegion
    private let radius: CLLocationDistance = 20 // 20미터 반경
    
    // 버스정류장 위치 객체
    private var stopLocation: BusStopLocation
    
    // 커스텀 초기화
    init(busStop: BusStopLocal) {
        self.busStop = busStop
        // 정류장 위치로 지도 중심 설정
        let coordinate = CLLocationCoordinate2D(
            latitude: Double(busStop.gpslati),
            longitude: Double(busStop.gpslong)
        )
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001) // 줌 레벨 조정
        ))
        
        self.stopLocation = BusStopLocation(
            coordinate: coordinate,
            title: busStop.nodenm
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("알림 예정 정류장 위치")
                .font(.regular16)
                .foregroundColor(.gray2)
                .padding(.horizontal, 20)
            
            ZStack {
                MapWithOverlay(region: $region,
                             userTrackingMode: $userTrackingMode,
                             stopLocation: stopLocation,
                             radius: radius)
                    .frame(height: 200)
                
                // 현재 위치로 이동하는 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            if let userLocation = locationManager.location?.coordinate {
                                withAnimation {
                                    region.center = userLocation
                                }
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }
}

// UIKit의 MKMapView를 SwiftUI에서 사용하기 위한 UIViewRepresentable
struct MapWithOverlay: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var userTrackingMode: MapUserTrackingMode
    let stopLocation: BusStopLocation
    let radius: CLLocationDistance
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = true
        
        // 핀 추가
        let annotation = MKPointAnnotation()
        annotation.coordinate = stopLocation.coordinate
        annotation.title = stopLocation.title
        mapView.addAnnotation(annotation)
        
        // 반경 원 추가
        let circle = MKCircle(center: stopLocation.coordinate, radius: radius)
        mapView.addOverlay(circle)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // region이 크게 변경되었을 때만 업데이트
        if abs(view.region.center.latitude - region.center.latitude) > 0.00001 ||
           abs(view.region.center.longitude - region.center.longitude) > 0.00001 ||
           abs(view.region.span.latitudeDelta - region.span.latitudeDelta) > 0.00001 ||
           abs(view.region.span.longitudeDelta - region.span.longitudeDelta) > 0.00001 {
            view.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapWithOverlay
        
        init(_ parent: MapWithOverlay) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
                renderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
