//
//  InputView.swift
//  Macro_Study_SwiftData
//
//  Created by 원주연 on 10/29/24.
//

import SwiftUI

struct InputViewDaisy: View {
    
    //알람을 수정할 때 편집할 Alert 데이터
    var alert: Alert? = nil
    
    @State private var newBusNumber: String = ""
    @State private var newBusStopName: String = ""
    @State private var newBusStopOrd: Int = 0 //정류장순번
    @State private var newBusStopGpsX: Double = 36.015231 //정류장x좌표(포스텍)
    @State private var newBusStopGpsY: Double = 129.325094 //정류장y좌표(포스텍)
    @State private var newAlertStopsBefore: Int = 2
    
//    @State private var newCityCode: Double
//    @State private var newBus: Bus
//    @State private var newArrivalBusStop: BusStop
//    @State private var newAlertBusStop: Int
//    @State private var newAlertLabel: String
//    @State private var newFirstBeforeBusStop: BusStop?
//    @State private var newSecondBeforeBusStop: BusStop?
//    @State private var newThirdBeforeBusStop: BusStop?
//    @State private var newAlertSound: UNNotificationSound?
//    @State private var newAlertHaptic: UIImpactFeedbackGenerator.FeedbackStyle?
//    @State private var newAlertCycle: Double
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    
    init(alert: Alert? = nil) {
        self.alert = alert
        //알람 데이터를 편집모드로 불러온 경우 해당 데이터로 초기화
        if let alert = alert {
            _newBusNumber = State(initialValue: alert.busNumber)
            _newBusStopName = State(initialValue: alert.busStopName)
            _newAlertStopsBefore = State(initialValue: alert.alertStopsBefore)
        }
    }
    
    func saveAlert() {
        // 기존 알람이 있으면 수정, 없으면 새로 추가
        if let alert = alert {
            alert.busNumber = newBusNumber
            alert.busStopName = newBusStopName
            alert.alertStopsBefore = newAlertStopsBefore
        } else {
            let newAlert = Alert(
                alertID: UUID(),
                busNumber: newBusNumber,
                busStopName: newBusStopName,
                busStopOrd: newBusStopOrd,
                busStopGpsX: newBusStopGpsX,
                busStopGpsY: newBusStopGpsY,
                alertStopsBefore: newAlertStopsBefore,
                isActivating: false)
            
//            let newAlert = Alert(
//                id: UUID(),
//                cityCode: newCityCode,
//                bus: newBus,
//                arrivalBusStop: newArrivalBusStop,
//                alertBusStop: newAlertBusStop,
//                alertLabel: newAlertLabel,
//                firstBeforeBusStop: newFirstBeforeBusStop,
//                secondBeforeBusStop: newSecondBeforeBusStop,
//                thirdBeforeBusStop: newThirdBeforeBusStop,
//                alertSound: newAlertSound,
//                alertHaptic: newAlertHaptic,
//                alertCycle: newAlertCycle)
            
            // ModelContext에 새로운 알람 추가
            modelContext.insert(newAlert)
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "bus")
                .imageScale(.large)
                .foregroundStyle(.tint)
            HStack{
                Text("버스 번호 :")
                TextField("버스 번호를 입력하세요", text: $newBusNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
            HStack {
                Text("버스 정류장 : ")
                TextField("버스 정류장 이름을 입력하세요", text: $newBusStopName)
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Text("몇 정류장 전 알림 : ")
                TextField("몇 정류장 전에 알림을 받을지 입력하세요", value: $newAlertStopsBefore, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                
            }
            Button(action: {
                saveAlert()
                dismiss()
            }, label: {
                Text("저장하기")
            })
        }.padding()
    }
}

#Preview {
    BellaBellaView()
}
