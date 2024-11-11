//
//  BusLocation.swift
//  BlueBerrySmoothie
//
//  Created by 이진경 on 11/6/24.
//

// BusLocation.swift
import Foundation

/// 버스 위치 정보를 나타내는 구조체
struct BusLocation: Identifiable {
    let id: UUID = UUID()  // 각 버스를 고유하게 식별하기 위한 ID
    let busID: String      // 버스의 고유 ID (버스 번호나 이름 등)
    let latitude: Double   // 버스의 위도
    let longitude: Double  // 버스의 경도
    
    // 다른 추가적인 정보를 넣고 싶다면 여기서 추가할 수 있음
    // 예를 들어, 버스의 이름, 노선 정보 등.
}
