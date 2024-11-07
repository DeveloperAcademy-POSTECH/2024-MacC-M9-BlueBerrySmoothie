//
//  StationPickerModal.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/5/24.
//
import SwiftUI

import SwiftUI

import SwiftUI

struct StationPickerModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedStation: String
    @Binding var alert: BusStopAlert? // BusStopAlert 값을 받아옴
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack {
                    HStack {
                        Text("목적지 전 정류장에서 알람")
                            .foregroundColor(Color(white: 72 / 255))
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                        Spacer()
                    }
                    
                    Divider()
                        .foregroundColor(Color(white: 212 / 255))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // 각 정류장 선택지
                    if let first = alert?.firstBeforeBusStop {
                        stationRow(stationText: "1 정거장 전", isEnabled: true) {
                            selectedStation = "1 정거장 전"
                            alert?.alertBusStop = 1
                            withAnimation {
                                isPresented = false
                            }
                        }
                    } else {
                        stationRow(stationText: "1 정거장 전", isEnabled: false)
                    }
                    
                    if let second = alert?.secondBeforeBusStop {
                        stationRow(stationText: "2 정거장 전", isEnabled: true) {
                            selectedStation = "2 정거장 전"
                            alert?.alertBusStop = 2
                            withAnimation {
                                isPresented = false
                            }
                        }
                    } else {
                        stationRow(stationText: "2 정거장 전", isEnabled: false)
                    }
                    
                    if let third = alert?.thirdBeforeBusStop {
                        stationRow(stationText: "3 정거장 전", isEnabled: true) {
                            selectedStation = "3 정거장 전"
                            alert?.alertBusStop = 3
                            withAnimation {
                                isPresented = false
                            }
                        }
                    } else {
                        stationRow(stationText: "3 정거장 전", isEnabled: false)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .transition(.move(edge: .bottom))
            }
            .ignoresSafeArea()
        }
    }
    
    // 선택지 행 뷰 구성 함수
    private func stationRow(stationText: String, isEnabled: Bool, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text(stationText)
                .foregroundColor(isEnabled ? Color(white: 128 / 255) : Color(white: 212 / 255))
                .onTapGesture {
                    if isEnabled, let action = action {
                        action()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            Spacer()
        }
    }
}
