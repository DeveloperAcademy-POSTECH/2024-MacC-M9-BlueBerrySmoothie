//
//  DetailView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/5/24.
//

import SwiftUI
import SwiftData

// Detail view for showing BusAlert details
struct DetailView: View {
    var alert: BusAlert

    // @Query에서 routeID를 사용할 수 있도록 수정
//    @Query(filter: #Predicate<BusStopLocal> { $0.routeid == "BSB5291412100"}, sort: [SortDescriptor(\BusStopLocal.nodeord)])
    @Query var busStopLocal: [BusStopLocal]


    var body: some View {
        
        let busStopLocal_ = busStopLocal.filter { $0.routeid == alert.routeid }.sorted { $0.nodeord < $1.nodeord }  
        VStack(alignment: .leading, spacing: 20) {
            Text("알람 레이블: \(alert.alertLabel)")
                .font(.headline)
            
            Text("버스 번호: \(alert.busNo)")
            Text("도착 정류장: \(alert.arrivalBusStopNm)")
            Text("도착 정류장 ID: \(alert.arrivalBusStopID)")
            Text("경로 ID: \(alert.routeid)") // alert.routeid 사용
            
            Spacer()
            
            List(busStopLocal_) { busstop in
                           VStack(alignment: .leading) {
                               Text(busstop.nodeid)
                                   .font(.headline)
                               Text("버스 번호: \(busstop.nodenm)")
                               Text("도시 코드: \(busstop.gpslati)")
                               Text("정류장 ID: \(busstop.gpslong)")
                               Text("\(busstop.nodeord)")
                           }
                       }

        }
        .padding()
        .navigationTitle("Alert Details")
    }
}
