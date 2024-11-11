//
//  SavedBus.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI

struct SavedBus: View {
//    @State private var busAlert: BusAlert // 수정 가능하게 변경
    let busAlert: BusAlert
    var isSelected: Bool = false
    var onDelete: () -> Void // 삭제 핸들러
    @State private var alertShowing = false
    @State private var isEditing = false
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.brand, lineWidth: 2)
                }
            VStack {
                HStack(alignment: .bottom) {
                    Text(busAlert.alertLabel)
                        .font(.regular12)
                        .foregroundColor(Color.brand)
                    Spacer()
                    Menu {
                        Button(action: {
                            // 수정
                            isEditing = true
                        }, label: {
                            Label("수정", systemImage: "pencil")
                        })
                        
                        Button(action: {
                            // 삭제
                            alertShowing = true
                        }, label: {
                            Label("삭제", systemImage: "trash")
                                .foregroundStyle(.red)
                        })
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.regular20)
                            .foregroundColor(Color.gray4)
                            .padding(.vertical, 20)
                    }
                    
                }
                HStack {
                    Text(busAlert.busNo)
                        .font(.regular20)
                    Text(busAlert.arrivalBusStopNm)
                        .font(.regular20)
                    
                    Spacer()
                }
                .foregroundColor(Color.black)
                .padding(.bottom, 4)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.regular12)
                        .foregroundColor(Color.brand)
                    Text("\(busAlert.alertBusStop) 정류장 전 알람")
                        .font(.regular14)
                        .foregroundColor(Color.brand)
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 2, height: 12)
                        .background(Color.gray5)
                    
                    Text(busAlert.alertBusStopNm)
                        .font(.regular14)
                        .foregroundColor(Color.gray3)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .fixedSize(horizontal: false, vertical: true)
        // `NavigationLink`를 사용하여 화면 전환
        NavigationLink(destination: AlertSettingMain(busAlert: busAlert, isEditing: isEditing ), isActive: $isEditing) {
            EmptyView() // 링크 표시하지 않음
        }
        //        .sheet(isPresented: $isEditing) {
        //            AlertSettingMain(busAlert: busAlert) // `busAlert`을 `AlertSettingMain`으로 전달
        //        }
        //        .sheet(isPresented: $isEditing) {
        ////            AlertSettingMain()
        //            AlertSettingMain(/*busAlert: busAlert*/) // `busAlert` 데이터 전달
        //        }
        .alert("알람 삭제", isPresented: $alertShowing) {
            Button("삭제", role: .destructive) {
                onDelete()
            }
            Button("취소", role: .cancel){}
        } message: {
            Text("알람을 삭제하시겠습니까?")
        }
    }
}

