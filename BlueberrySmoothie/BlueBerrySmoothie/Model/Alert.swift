//
//  BusStop.swift
//  Macro_Study_SwiftData
//
//  Created by 원주연 on 10/28/24.
//

import Foundation
import SwiftData

@Model
class Alert {
    @Attribute(.unique) var busStopID: UUID //정류장코드
    var busNumber: String //버스번호
    var busStopName: String // 정류장이름
    var alertStopsBefore: Int //몇정류장 전에 알림을 줄지
    var isActivating: Bool //알람이 활성화 되어 있는지
    
    init(busStopID: UUID, busNumber: String, busStopName: String, alertStopsBefore: Int, isActivating: Bool) {
        self.busStopID = busStopID
        self.busNumber = busNumber
        self.busStopName = busStopName
        self.alertStopsBefore = alertStopsBefore
        self.isActivating = false
    }
}
