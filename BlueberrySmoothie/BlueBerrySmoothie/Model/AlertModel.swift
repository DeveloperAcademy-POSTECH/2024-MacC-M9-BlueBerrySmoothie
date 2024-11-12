//
//  AlertModel.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 11/2/24.
//

import Foundation
import SwiftUI

import SwiftData

@Model
class BusAlert {
    var id: String
    var cityCode: Double // 도시코드
    var busNo: String // 노선(버스번호)
    var routeid: String // 노선(버스번호) id
    var arrivalBusStopID: String // 도착 정류소 id
    var arrivalBusStopNm: String // 도착 정류소명
    var arrivalBusStopNord: Int // 도착 정류소명
    var alertBusStop: Int // 몇 번째 전에 알람
    var alertBusStopID: String // 알람 정류소 id
    var alertBusStopNm: String // 알람 정류소명
    var alertLabel: String? // 알람 이름
    var alertSound: Bool? // 알람 사운드 (옵셔널)
    var alertHaptic: Bool? // 알람 진동 (옵셔널)
    var alertCycle: Double? // 알람 주기 (옵셔널)
    var updowncd: Int
    
    init(id: String, cityCode: Double, busNo: String, routeid: String, arrivalBusStopID: String, arrivalBusStopNm: String, arrivalBusStopNord: Int ,alertBusStop: Int, alertBusStopID: String, alertBusStopNm: String, alertLabel: String, alertSound: Bool? = nil, alertHaptic: Bool? = nil, alertCycle: Double? = nil, updowncd: Int) {
        self.id = id
        self.cityCode = cityCode
        self.busNo = busNo
        self.routeid = routeid
        self.arrivalBusStopID = arrivalBusStopID
        self.arrivalBusStopNm = arrivalBusStopNm
        self.arrivalBusStopNord = arrivalBusStopNord
        self.alertBusStop = alertBusStop
        self.alertBusStopID = alertBusStopID
        self.alertBusStopNm = alertBusStopNm
        self.alertLabel = alertLabel
        self.alertSound = alertSound
        self.alertHaptic = alertHaptic
        self.alertCycle = alertCycle
        self.updowncd = updowncd
    }
}

@Model
class BusStopLocal {
    var id: String
    var routeid: String // 노선(버스번호) id
    var nodeid: String // 정류소 id
    var nodenm: String // 정류소명
    var nodeno: Int? // 정류소 번호
    var nodeord: Int // 정류소 순번
    var gpslati: Double // 정류소 latitude 좌표 (위도)
    var gpslong: Double // 정류소 longtitude 좌표 (경도)
    var updowncd: Int
    
    init(id: String, routeid: String, nodeid: String, nodenm: String, nodeno: Int? = nil, nodeord: Int, gpslati: Double, gpslong: Double, updowncd: Int) {
        self.id = id
        self.routeid = routeid
        self.nodeid = nodeid
        self.nodenm = nodenm
        self.nodeno = nodeno
        self.nodeord = nodeord
        self.gpslati = gpslati
        self.gpslong = gpslong
        self.updowncd = updowncd
    }
}



// 알람 등록뷰에서 사용할 Alert 모델
struct BusStopAlert: Identifiable {
    var id = UUID()
    var cityCode: Double // 도시코드
    var bus: Bus // 버스 번호, 노선d id 저장되어있음
    var allBusStop: [BusStop]
    var arrivalBusStop: BusStop // 도착 정류장
    var alertBusStop: Int // 알람 줄 정류장
    var firstBeforeBusStop: BusStop? // 1번째 전 정류장
    var secondBeforeBusStop: BusStop? // 2번째 전 정류장
    var thirdBeforeBusStop: BusStop? // 3번째 전 정류장
}


func findAlertBusStop(busAlert: BusAlert, busStops: [BusStopLocal]) -> BusStopLocal? {
    // 1. BusStopLocal에서 routeid가 동일한 노선 찾기
    let filteredStops = busStops.filter { $0.routeid == busAlert.routeid }
    
    // 2. 도착 정류소 ID에 해당하는 정류소 찾기
    guard let arrivalStop = filteredStops.first(where: { $0.nodeid == busAlert.arrivalBusStopID }) else {
        return nil // 도착 정류소가 없으면 nil 반환
    }
    
    // 3. 도착 정류소의 nodeord에서 alertBusStop을 뺀 정류소 찾기
    let targetNodeOrd = arrivalStop.nodeord - busAlert.alertBusStop
    
    // 4. 해당 nodeord에 해당하는 정류소 반환
    return filteredStops.first(where: { $0.nodeord == targetNodeOrd })
}
