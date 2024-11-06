//
//  alertSettingMain.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/1/24.
//

import SwiftUI
import SwiftData

// AlertSettingMain 뷰
struct AlertSettingMain: View {
    
    @Environment(\.modelContext) private var modelContext // ModelContext를 가져옴
    @Environment(\.dismiss) var dismiss
    @Query var busStopLocal: [BusStopLocal]
    @State private var label: String = ""
    @State private var showSheet: Bool = false
    @State private var selectedStation: String = "정거장 수"
//    @State private var selectedBus: Bus?  // Bus 구조체를 저장하는 변수
//    @State private var selectedBusStop: BusStop? // 선택된 정류장을 위한 State
//    @State private var allBusstop: [BusStop] = []
    @State private var busStopAlert: BusStopAlert?

    var body: some View {
        NavigationStack {
            VStack {
                // 데이터 확인 버튼
                Button(action: {
                    print("\(busStopAlert?.bus.routeno ?? "선택 안됨")")
                    print("\(busStopAlert?.bus.routeid ?? "선택 안됨")")
                    print("\(busStopAlert?.arrivalBusStop.nodeid ?? "선택 안됨")")
                }) {
                    Text("데이터 확인")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                HStack {
                    Text("알람 설정")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                }
                .padding(.bottom, 8)

                HStack {
                    Text("종착지에 도착하기 전에 깨워드려요")
                        .font(.system(size: 16))
                        .foregroundColor(Color(white: 170 / 255))
                    Spacer()
                }
                .padding(.bottom, 36)

                VStack {
                    HStack(spacing: 2) {
                        Text("버스 및 종착지")
                        Image(systemName: "asterisk")
                            .foregroundColor(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255))
                            .font(.system(size: 10, weight: .bold))
                            .padding(.trailing)

                        ZStack {
                            Rectangle()
                                .foregroundColor(Color(white: 247 / 255))
                                .cornerRadius(8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(white: 212 / 255), lineWidth: 1)
                                }
                            HStack {
                                Text(busStopAlert?.bus.routeno ?? "선택 안됨")  // 선택된 버스 표시
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                Spacer()
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)

                        NavigationLink(destination: SelectBusView( busStopAlert: $busStopAlert)) {  // 선택된 버스를 전달받음
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color(red: 237 / 255, green: 239 / 255, blue: 246 / 255))
                                    .cornerRadius(20)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255), lineWidth: 1)
                                    }
                                Text("버스 찾기")
                                    .padding(12)
                            }
                        }
                        .fixedSize()
                    }
                }
                HStack {
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    // 선택된 정류장 표시
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(white: 247 / 255))
                            .cornerRadius(8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(white: 212 / 255), lineWidth: 1)
                            }
                        HStack {
                            Text("\(busStopAlert?.arrivalBusStop.nodenm ?? "선택해주세요")")
                                .font(.system(size: 16))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            Spacer()
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 20)
                }
                HStack(spacing: 2) {
                    Text("일어날 정류장")
                    Image(systemName: "asterisk")
                        .foregroundColor(Color(red: 104/255, green: 144/255, blue: 255/255))
                        .font(.system(size: 10, weight: .bold))
                        .padding(.trailing)
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(white: 212/255), lineWidth: 1)
                            }
                        
                        HStack {
                            Text(selectedStation)
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color(white: 170/255))
                                .font(.system(size: 16))
                        }
                        .font(.system(size: 16))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .onTapGesture {
                        showSheet = true
                    }
                    
                    Spacer()
                    Spacer()
                    Text("전에 알람")
                }
                .padding(.bottom, 20)
                // 알람 레이블 입력 필드
                HStack {
                    Text("알람 레이블")
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(white: 212 / 255), lineWidth: 1)
                            }
                        HStack {
                            TextField("통학", text: $label)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                            Spacer()
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(20)
            .overlay {
                if showSheet {
                    StationPickerModal(isPresented: $showSheet, selectedStation: $selectedStation)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    saveAlert()
                    saveBusstop()
                    dismiss()
                }) {
                    Text("저장")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255))
                }
            }
        }
    }
    
    // 알람 저장 함수
    private func saveAlert() {
        guard let selectedBus = busStopAlert?.bus,
              let selectedBusStop = busStopAlert?.arrivalBusStop else {
            print("버스와 정류장을 선택하세요.")
            return
        }

        // 알람 객체 생성
        let newAlert = BusAlert(id: UUID().uuidString,
                                 cityCode: 21, // 예시로 cityCode 설정
                                 busNo: selectedBus.routeno, // 선택된 버스의 번호
                                 routeid: selectedBus.routeid, // 선택된 버스의 routeid
                                 arrivalBusStopID: selectedBusStop.nodeid, // 선택된 정류장의 ID
                                 arrivalBusStopNm: selectedBusStop.nodenm,
                                 alertBusStop: 1, // 사용자가 설정한 알람 줄 정류장
                                 alertLabel: label, // 사용자가 입력한 알람 레이블
                                 alertSound: true, // 알람 사운드 활성화
                                 alertHaptic: true, // 해프틱 피드백 활성화
                                 alertCycle: nil,
                                 updowncd: selectedBusStop.updowncd)

        // 데이터베이스에 저장
        do {
            try modelContext.insert(newAlert) // 모델 컨텍스트에 추가
            print("알람이 저장되었습니다.")
        } catch {
            print("알람 저장 실패: \(error)")
        }
    }
    
    
    private func saveBusstop() {
        guard !(busStopAlert?.allBusStop.isEmpty)! else {
            print("버스를 선택하세요.")
            return
        }
        
        // selectedBus.routeid가 이미 존재하는지 확인
        let routeExists = busStopLocal.contains { existingBusStop in
            existingBusStop.routeid == busStopAlert?.bus.routeid
        }

        // 같은 routeid가 존재하면 저장하지 않음
        if routeExists {
            print("routeid \(busStopAlert?.bus.routeid ?? "알 수 없음")이 이미 존재합니다. 저장하지 않았습니다.")
            return // 중복된 경우, 함수 종료
        }

        // routeid가 존재하지 않으면 저장
        for busStop in busStopAlert!.allBusStop {
            let newBusStopLocal = BusStopLocal(
                id: UUID().uuidString,
                routeid: busStop.routeid,
                nodeid: busStop.nodeid,
                nodenm: busStop.nodenm,
                nodeno: busStop.nodeno,
                nodeord: busStop.nodeord,
                gpslati: busStop.gpslati,
                gpslong: busStop.gpslong,
                updowncd: busStop.updowncd
            )
            
            // 데이터베이스에 저장
            do {
                try modelContext.insert(newBusStopLocal) // 모델 컨텍스트에 추가
                print("버스 정류장이 저장되었습니다.")
            } catch {
                print("버스 정류장 저장 실패: \(error)")
            }
        }
    }
}


#Preview {
    AlertSettingMain()
}
