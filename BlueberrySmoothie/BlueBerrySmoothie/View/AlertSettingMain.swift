import SwiftUI
import SwiftData

// AlertSettingMain 뷰
struct AlertSettingMain: View {
    @Environment(\.modelContext) private var modelContext // ModelContext를 가져옴
    @Environment(\.dismiss) private var dismiss
    @Query var busStopLocal: [BusStopLocal]
    
    var busAlert: BusAlert? // 편집을 위한 `busAlert` 매개변수 추가
    var isEditing: Bool = false
    
    // 초기화 데이터들
    @State private var label: String = "알람"
    @State private var selectedStation: String = "정류장 수"
    
    // 사용자 입력을 받을 cityCode
    @State private var cityCodeInput: String = "" // ← 추가된 상태 변수
    
    // 추가된 상태 변수: SelectBusView를 sheet로 표시할지 여부
    @State private var showSelectBusSheet: Bool = false // ← 추가된 부분
    @State private var busStopAlert: BusStopAlert? // 사용자 선택 사항
    @State private var showSheet: Bool = false
    
    // 토스트 메시지 상태 변수
    @State private var showToast = false
    @State private var toastMessage = ""
    
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
                
                // City Code 입력 필드
                HStack {
                    Text("도시 코드")
                        .foregroundColor(Color.black)
                        .font(.regular16)
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
                            TextField("예: 21", text: $cityCodeInput, prompt: Text("도시 코드 입력").foregroundColor(Color.gray4))
                                .keyboardType(.numberPad)
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
                .padding(.bottom, 20)
                
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
                                SelectBusView(cityCode: Int(cityCodeInput) ?? 21, busStopAlert: $busStopAlert,showSelectBusSheet: $showSelectBusSheet)
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
                
                // 일어날 정류장 선택
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
                            Text("\(selectedStation)")
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
        .onAppear {
//            print("AlertSettingMain onAppear: \(busAlert?.alertLabel)")
            // 이전 정류장 수 선택이 안되어있는 경우
            if busStopAlert?.alertBusStop == 0 {
                selectedStation = "정류장 수"
            }
            
            // 수정인 경우
            if let busAlert = busAlert {
                // `busAlert` 데이터로 초기 상태 설정
                label = busAlert.alertLabel ?? "알람"
                selectedStation = "\(busAlert.alertBusStop) 정류장 전에 알람"
                
                busStopAlert = BusStopAlert(
                    cityCode: busAlert.cityCode,
                    bus: Bus(routeno: busAlert.busNo, routeid: busAlert.routeid),
                    allBusStop: [],
                    arrivalBusStop: BusStop(nodeid: busAlert.arrivalBusStopID, nodenm: busAlert.arrivalBusStopNm),
                    alertBusStop: busAlert.alertBusStop // 필요에 따라 전체 정류장 데이터 설정
                )
            }
        }
        .overlay {
            if showSheet {
                StationPickerModal(isPresented: $showSheet, selectedStation: $selectedStation, alert: $busStopAlert, nodeord: busAlert?.arrivalBusStopNord ?? 0)
            } else {
                EmptyView()
            }
        }
        .toolbar {
            // 저장 버튼
            ToolbarItem {
                Button(action: {
                    if isInputValid() {
                        saveOrUpdateAlert()
                        saveBusstop()
                        dismiss()
                    } else {
                        showToastMessage("모든 정보를 입력해주세요.")
                    }
                }) {
                    Text("저장")
                        .font(.regular16)
                        .foregroundColor(Color.brand)
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
        .toast(isShowing: $showToast, message: toastMessage)
    }
    
    private func isInputValid() -> Bool {
        return selectedStation != "정류장 수" && busStopAlert?.bus != nil && busStopAlert?.arrivalBusStop != nil
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
    }
    
    // 알람 저장 함수
    private func saveOrUpdateAlert() {
        // 기존 알람 수정
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
    
    // 새 알림 저장 함수
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
        
        
        let cityCode = Int(cityCodeInput) ?? -1 // 도시 코드 유효성 확인
        guard cityCode > 0 else {
            print("유효한 도시 코드를 입력하세요.")
            showToastMessage("유효한 도시 코드를 입력하세요.")
            return
        }

        // 알람 객체 생성
        let newAlert = BusAlert(
            id: UUID().uuidString,
            cityCode: Double(cityCode), // 사용자가 입력한 도시 코드
            busNo: selectedBus.routeno,
            routeid: selectedBus.routeid,
            arrivalBusStopID: selectedBusStop.nodeid,
            arrivalBusStopNm: selectedBusStop.nodenm,
            arrivalBusStopNord: selectedBusStop.nodeord,
            alertBusStop: busStopAlert!.alertBusStop,
            alertLabel: label,
            alertSound: true,
            alertHaptic: true,
            alertCycle: nil,
            updowncd: selectedBusStop.updowncd ?? 1
        )
        
        // 데이터베이스에 저장
        do {
            try modelContext.insert(newAlert)
            print("알람이 저장되었습니다.")
        } catch {
            print("알람 저장 실패: \(error)")
        }
    }
    
    // 선택한 버스의 정류장 List 저장 함수 - UsingAlertView에서 정류장 노선을 띄우는데 사용됨
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
                updowncd: busStop.updowncd ?? 1
            )
            
            do {
                try modelContext.insert(newBusStopLocal)
                //                print("버스 정류장이 저장되었습니다.")
            } catch {
                print("버스 정류장 저장 실패: \(error)")
            }
        }
    }
}
