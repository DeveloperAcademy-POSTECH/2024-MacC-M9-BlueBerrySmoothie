//
//  StationPickerModal.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/5/24.
//
import SwiftUI

struct StationPickerModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedStation: String
    let stations = ["1 정거장 전", "2 정거장 전", "3 정거장 전"]
    
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
                    
                    ForEach(stations, id: \.self) { station in
                        HStack {
                            Text(station)
                                .foregroundColor(Color(white: 128 / 255))
                                .onTapGesture {
                                    selectedStation = station
                                    withAnimation {
                                        isPresented = false
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                            Spacer()
                        }
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
}
