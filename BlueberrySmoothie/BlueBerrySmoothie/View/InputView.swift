//
//  InputView.swift
//  Macro_Study_SwiftData
//
//  Created by 원주연 on 10/29/24.
//

import SwiftUI

struct InputView: View {
    
    //알람을 수정할 때 편집할 Alert 데이터
    var alert: Alert? = nil
    
    @State private var newBusNumber: String = ""
    @State private var newBusStopName: String = ""
    @State private var newAlertStopsBefore: Int = 2
    
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
            let newAlert = Alert(busStopID: UUID(), busNumber: newBusNumber, busStopName: newBusStopName, alertStopsBefore: newAlertStopsBefore, isActivating: false)
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
    InputView()
}
