//
//  File.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/1/24.
//

import SwiftUI

// 버스 타입에 따른 색상을 반환하는 함수
func busColor(for routetp: String) -> Color {
    switch routetp {
    case "일반버스", "간선버스": return .blue
    case "마을버스", "지선버스": return .green
    case "급행버스", "광역버스": return .red
    case "순환버스": return .yellow
    default: return .primary
    }
}
