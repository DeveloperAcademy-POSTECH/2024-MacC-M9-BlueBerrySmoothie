//
//  Alert.swift
//  Macro_Study_SwiftData
//
//  Created by 원주연 on 10/28/24.
//

import Foundation
import SwiftData

@Model
class Alert {
    @Attribute(.unique) var alertID = UUID() //알람코드
    var busNumber: String //버스번호
    var busStopName: String // 정류장이름
    var busStopOrd: Int //정류장순번
    var busStopGpsX: Double //정류장x좌표
    var busStopGpsY: Double //정류장y좌표
    var alertStopsBefore: Int //몇 정거장 전에 알림을 줄지
    var isActivating: Bool //알람이 활성화 되어 있는지
    
    init(alertID: UUID, busNumber: String, busStopName: String, busStopOrd: Int, busStopGpsX: Double, busStopGpsY: Double, alertStopsBefore: Int, isActivating: Bool) {
        self.alertID = alertID
        self.busNumber = busNumber
        self.busStopName = busStopName
        self.busStopOrd = busStopOrd
        self.busStopGpsX = busStopGpsX
        self.busStopGpsY = busStopGpsY
        self.alertStopsBefore = alertStopsBefore
        self.isActivating = false
    }
}
