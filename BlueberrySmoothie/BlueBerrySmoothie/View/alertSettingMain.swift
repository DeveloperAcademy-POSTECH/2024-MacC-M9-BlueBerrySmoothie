//
//  alertSettingMain.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/1/24.
//

import SwiftUI

struct alertSettingMain: View {
    
    @State private var label: String = ""
    @State private var showSheet: Bool = false
    @State private var selectedStation: String = "정거장 수"
    
    var body: some View {
        VStack {
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
                            Text("207(일반)")
                                .font(.system(size: 16))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            Spacer()
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    Spacer()
                    
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
                    .fixedSize()
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
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(white: 247 / 255))
                            .cornerRadius(8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(white: 212 / 255), lineWidth: 1)
                            }
                        HStack {
                            Text("포스텍")
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
                
                HStack {
                    Text("알람 레이블")
                    
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
                            TextField("통학", text : $label)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                            Spacer()
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
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
}

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

#Preview {
    alertSettingMain()
}
