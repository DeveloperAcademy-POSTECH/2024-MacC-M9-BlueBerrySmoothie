//
//  BusDetailView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/1/24.
//


import SwiftUI

// 가정: BusDetailView는 Bus 객체를 받아서 상세 정보를 표시하는 View입니다.
struct BusDetailView: View {
    let bus: Bus

    var body: some View {
        VStack(alignment: .leading) {
            Text("노선 번호: \(bus.routeno)")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            Text("노선 타입: \(bus.routetp)")
                .foregroundColor(.secondary)
            
            Text("출발 정류장: \(bus.startnodenm)")
            Text("도착 정류장: \(bus.endnodenm)")
            
            Text("출발 시간: \(bus.startvehicletime)")
            Text("도착 시간: \(bus.endvehicletime)")
            
            Spacer()
        }
        .padding()
        .navigationTitle("버스 상세 정보")
    }
}