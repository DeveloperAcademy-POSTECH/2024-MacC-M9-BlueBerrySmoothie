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

//class Alert: Identifiable {
//    @Attribute(.unique) var id = UUID()
//    var cityCode: Double // 도시코드 부산(21)
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
//
//    init(id: UUID, cityCode: Double, bus: Bus, arrivalBusStop: BusStop, alertBusStop: Int, alertLabel: String, firstBeforeBusStop: BusStop?, secondBeforeBusStop: BusStop?, thirdBeforeBusStop: BusStop?, alertSound: UNNotificationSound?, alertHaptic: UIImpactFeedbackGenerator.FeedbackStyle?, alertCycle: Double) {
//      self.id = id
//      self.cityCode = cityCode
//      self.bus = bus
//      self.arrivalBusStop = arrivalBusStop
//      self.alertBusStop = alertBusStop
//      self.alertLabel = alertLabel
//      self.firstBeforeBusStop = firstBeforeBusStop
//      self.secondBeforeBusStop = secondBeforeBusStop
//      self.thirdBeforeBusStop = thirdBeforeBusStop
//      self.alertSound = alertSound
//      self.alertHaptic = alertHaptic
//      self.alertCycle = alertCycle
//}
