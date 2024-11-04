//
//  AlertModel.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 11/2/24.
//

import Foundation
import SwiftUI

//import SwiftData
//
//@Model
struct Alert {
/*    @Attribute(.primaryKey)*/ var id: String
    var cityCode: Double // 도시코드
    var busNo: String
    var routeid: String
    var arrivalBusStopID: String
    var alertBusStop: Int // 알람 줄 정류장
    var alertLabel: String // 알람 이름
    var alertSound: Bool // 알람 사운드 (옵셔널)
    var alertHaptic: Bool // 알람 진동 (옵셔널)
    var alertCycle: Double // 알람 주기 (옵셔널)
    
}


//@Model
struct BusStopLocal {
/*    @Attribute(.primaryKey) */var id: String
    var routeid: String
    var nodeid: String
    var nodenm: String
    var nodeno: Int?
    var nodeord: Int
    var gpslati: Double
    var gpslong: Double
    var updowncd: Int

}
//struct Alert: Identifiable {
//    var id = UUID()
//    var cityCode: Double // 도시코드
//    var bus: Bus // 버스 번호, 노선 id 저장되어있음
//    var arrivalBusStop: BusStop // 도착 정류장
//    var alertBusStop: Int // 알람 줄 정류장
//    var alertLabel: String // 알람 이름
//    var firstBeforeBusStop: BusStop? // 1번째 전 정류장
//    var secondBeforeBusStop: BusStop? // 2번째 전 정류장
//    var thirdBeforeBusStop: BusStop? // 3번째 전 정류장
//    var alertSound: UNNotificationSound? // 알람 사운드 (옵셔널)
//    var alertHaptic: UIImpactFeedbackGenerator.FeedbackStyle? //알람 진동 (옵셔널)
//    var alertCycle: Double //알람 주기 (옵셔널)
//}
