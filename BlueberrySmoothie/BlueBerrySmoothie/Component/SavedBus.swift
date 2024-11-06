//
//  SavedBus.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI

struct SavedBus: View {
    let busAlert: BusAlert
    var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255), lineWidth: 2)
                }
            VStack {
                HStack(alignment: .bottom) {
                    Text(busAlert.alertLabel)
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 128 / 255))
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                            .foregroundColor(Color(white: 212 / 255))
                            .padding(.vertical, 20)
                    })
                }
                HStack {
                    Text(busAlert.busNo)
                        .font(.system(size: 20, weight: .regular))
                    Text(busAlert.arrivalBusStopNm)
                        .font(.system(size: 20, weight: .regular))
                    Spacer()
                }
                .padding(.bottom, 4)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255))
                    Text("\(busAlert.alertBusStop) 정류장 전 알람")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255))
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 2, height: 12)
                        .background(Color(white: 238 / 255))
                    
                    Text(busAlert.arrivalBusStopNm)
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 170 / 255))

                    Spacer()
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

