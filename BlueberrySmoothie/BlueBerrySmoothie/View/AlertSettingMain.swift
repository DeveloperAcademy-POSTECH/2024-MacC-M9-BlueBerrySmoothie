import SwiftUI
import SwiftData

// AlertSettingMain 뷰
struct AlertSettingMain: View {
    @Environment(\.modelContext) private var modelContext // ModelContext를 가져옴
    @Environment(\.dismiss) private var dismiss
    @Query var busStopLocal: [BusStopLocal]

    var busAlert: BusAlert? // 편집을 위한 `busAlert` 매개변수 추가
    var isEditing: Bool = false // 편집을 위한 `busAlert` 매개변수 추가
    
    // 초기화 데이터들
    @State private var label: String = ""
    @State private var selectedStation: String = "정류장 수"

    @Binding var showSetting: Bool
    
    // 추가된 상태 변수: SelectBusView를 sheet로 표시할지 여부
    @State private var showSelectBusSheet: Bool = false // ← 추가된 부분

    @State private var busStopAlert: BusStopAlert? // 사용자 선택 사항
    @State private var showSheet: Bool = false
    
    init(busAlert: BusAlert? = nil, isEditing: Bool? = nil) {
        self.busAlert = busAlert
        self.isEditing = isEditing ?? false
        
    }

    

    var body: some View {
            ZStack {
                VStack {
                    HStack {
                        Text("알람 설정")
                            .font(.medium24)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        Text("종착지에 도착하기 전에 깨워드려요")
                            .font(.regular16)
                            .foregroundColor(Color.gray3)
                        Spacer()
                    }
                    .padding(.bottom, 36)
                    
                    VStack {
                        HStack(spacing: 2) {
                            Text("버스 및 종착지")
                                .foregroundColor(.black)
                                .font(.regular16)
                            Image(systemName: "asterisk")
                                .foregroundColor(Color.brand)
                                .font(.regular10)
                                .bold()
                                .padding(.trailing)
                            
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color.gray6)
                                    .cornerRadius(8)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray4, lineWidth: 1)
                                    }
                                HStack {
                                    Text(busStopAlert?.bus.routeno ?? "선택 안됨")  // 선택된 버스 표시
                                        .font(.regular16)
                                        .foregroundColor(Color.black)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    Spacer()
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            Spacer()

                           if isEditing == false {
                           Button(action: {
                                showSelectBusSheet = true // sheet 표시 상태를 true로 설정
                            }) {  // 선택된 버스를 전달받음
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color.lightbrand)
                                        .cornerRadius(20)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.brand, lineWidth: 1)
                                        }
                                    Text("버스 찾기")
                                        .font(.caption2)
                                        .foregroundColor(Color.black)
                                        .padding(12)
                                }
                            }
                            .fixedSize()
                            .sheet(isPresented: $showSelectBusSheet) { // ← 수정된 부분
                                SelectBusView(busStopAlert: $busStopAlert,showSelectBusSheet: $showSelectBusSheet)
                            }

                           }

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
                        
                        // 선택된 정류장 표시
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color.gray6)
                                .cornerRadius(8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray4, lineWidth: 1)
                                }
                            HStack {
                                Text("\(busStopAlert?.arrivalBusStop.nodenm ?? "선택해주세요")")
                                    .foregroundColor(Color.black)
                                    .font(.regular16)
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
                            .font(.medium16)
                            .foregroundColor(Color.black)
                        Image(systemName: "asterisk")
                            .foregroundColor(Color.brand)
                            .font(.regular10)
                            .bold()
                            .padding(.trailing)
                        
                        ZStack {
                            Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray4, lineWidth: 1)
                                }
                            
                            HStack {
                                Text(selectedStation)
                                    .foregroundColor(Color.black)
                                    .font(.regular16)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color.gray3)
                                    .font(.regular10)
                            }
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
                            .foregroundColor(Color.gray1)
                            .font(.regular16)
                    }
                    .padding(.bottom, 20)
                    
                    // 알람 레이블 입력 필드
                    HStack {
                        Text("알람 레이블")
                            .foregroundColor(Color.black)
                            .font(.regular16)
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
                                        .stroke(Color.gray4, lineWidth: 1)
                                }
                            HStack {
                                TextField("통학", text: $label, prompt: Text("통학").foregroundColor(Color.gray4))
                                    .foregroundColor(Color.black)
                                    .font(.regular16)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                Spacer()
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 10)
                    }
                    
                    Spacer()
                }
                .padding(20)
                Spacer()
            }
            .padding(20)
            .onAppear {
                //                loadData() // 저장된 데이터 로드
                if let busAlert = busAlert {
                    // `busAlert` 데이터로 초기 상태 설정
                    label = busAlert.alertLabel
                    selectedStation = "\(busAlert.alertBusStop) 정류장"
                    
                    busStopAlert = BusStopAlert(
                        cityCode: busAlert.cityCode,
                        bus: Bus(routeno: busAlert.busNo, routeid: busAlert.routeid),
                        allBusStop: [],
                        arrivalBusStop: BusStop(nodeid: busAlert.arrivalBusStopID, nodenm: busAlert.arrivalBusStopNm),
                        alertBusStop: busAlert.alertBusStop // 필요에 따라 전체 정류장 데이터 설정
                    )
                }
            }
            .onAppear {
                if busStopAlert?.alertBusStop == 0 {
                    selectedStation = "정류장 수"
                }
            }
//            .background(Color.white)
            .overlay {
                if showSheet {
                    StationPickerModal(isPresented: $showSheet, selectedStation: $selectedStation, alert: $busStopAlert, nodeord: busAlert?.arrivalBusStopNord ?? 0)
                } else {
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        if selectedStation != "정류장 수" && label != "" {
                            saveOrUpdateAlert()
                            saveBusstop()
                            dismiss()
                        }
                    }) {
                        Text("저장")
                            .font(.regular16)
                        .foregroundColor(Color.brand)
                    }
                }
            }
            // 닫기 버튼
               ToolbarItem(placement: .navigationBarLeading) {
                   Button(action: {
                       dismiss()  // 현재 화면을 닫는 동작
                   }) {
                       Text("닫기")
                           .font(.regular16)
                           .foregroundColor(Color.brand) // 원하는 색상으로 변경 가능
                   }
               }
        }
        
        
    }
    
    // 저장된 `BusAlert` 데이터를 불러와 UI에 반영하는 메서드
    //    private func loadData() {
    //        guard let busAlert = busAlert else { return }
    //
    //        // 기본적으로 `BusAlert` 데이터를 UI 상태에 반영
    //        label = busAlert.alertLabel
    //        selectedStation = "\(busAlert.alertBusStop) 정류장 전 알람"
    //
    //        // `BusStopAlert`로 변환하여 사용
    //        busStopAlert = BusStopAlert(
    //            cityCode: busAlert.cityCode, bus: Bus(routeid: busAlert.routeid, routeno: busAlert.busNo),
    //            arrivalBusStop: BusStop(
    //                nodeid: busAlert.arrivalBusStopID,
    //                nodenm: busAlert.arrivalBusStopNm
    //            ),
    //            alertBusStop: busAlert.alertBusStop, // cityCode 추가
    //                    allBusStop: [] // allBusStop은 빈 배열로 초기화하거나 필요한 값으로 설정
    //        )
    //    }
    
    private func saveOrUpdateAlert() {
        if isEditing == true {
            // 기존 `busAlert` 업데이트
            busAlert?.alertLabel = label
            busAlert?.alertBusStop = busStopAlert?.alertBusStop ?? 3
            // 추가 필드 업데이트
            print("알람이 업데이트되었습니다.")
        } else {
            // 새 알림을 저장 (편집 모드가 아닌 경우)
            saveAlert()
        }
    }
    
    // 알람 저장 함수
    private func saveAlert() {
        guard let selectedBus = busStopAlert?.bus,
              let selectedBusStop = busStopAlert?.arrivalBusStop else {
            print("버스와 정류장을 선택하세요.")
            return
        }
        
        var selectedAlertBusStop: BusStop?
        
        if busStopAlert!.alertBusStop == 1 {
            guard let alertBusStop = busStopAlert?.firstBeforeBusStop else {
                print("다시")
                return
            }
            selectedAlertBusStop = alertBusStop
        } else if busStopAlert!.alertBusStop == 2 {
            guard let alertBusStop = busStopAlert?.secondBeforeBusStop else {
                print("다시")
                return
            }
            selectedAlertBusStop = alertBusStop
        } else {
            guard let alertBusStop = busStopAlert?.thirdBeforeBusStop else {
                print("다시")
                return
            }
            selectedAlertBusStop = alertBusStop
        }
        
        // Ensure selectedAlertBusStop is non-nil before proceeding
        guard let finalAlertBusStop = selectedAlertBusStop else {
            print("알람 정류장 선택 오류")
            return
        }
        
        // 알람 객체 생성
        let newAlert = BusAlert(id: UUID().uuidString,
                                cityCode: 21,
                                busNo: selectedBus.routeno,
                                routeid: selectedBus.routeid,
                                arrivalBusStopID: selectedBusStop.nodeid,
                                arrivalBusStopNm: selectedBusStop.nodenm,
                                arrivalBusStopNord: selectedBusStop.nodeord,
                                alertBusStop: busStopAlert!.alertBusStop, // 사용자가 설정한 알람 줄 정류장
                                alertBusStopID: finalAlertBusStop.nodeid,
                                alertBusStopNm: finalAlertBusStop.nodenm ,
                                alertLabel: label, // 사용자가 입력한 알람 레이블
                                alertSound: true, // 알람 사운드 활성화
                                alertHaptic: true, // 해프틱 피드백 활성화
                                alertCycle: nil,
                                updowncd: selectedBusStop.updowncd)
        
        // 데이터베이스에 저장
        do {
            try modelContext.insert(newAlert)
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
        
        let routeExists = busStopLocal.contains { existingBusStop in
            existingBusStop.routeid == busStopAlert?.bus.routeid
        }
        
        if routeExists {
            print("routeid \(busStopAlert?.bus.routeid ?? "알 수 없음")이 이미 존재합니다. 저장하지 않았습니다.")
            return
        }
        
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
            
            do {
                try modelContext.insert(newBusStopLocal)
                print("버스 정류장이 저장되었습니다.")
            } catch {
                print("버스 정류장 저장 실패: \(error)")
            }
        }
    }
}
