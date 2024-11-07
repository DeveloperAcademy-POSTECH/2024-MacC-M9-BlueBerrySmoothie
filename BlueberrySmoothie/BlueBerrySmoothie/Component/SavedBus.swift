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
                        .foregroundColor(Color.gray2)
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "ellipsis")
                        .font(.regular20)
                        .foregroundColor(Color.gray4)
                        .padding(.vertical, 20)
                    })
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
                    

                    Text(busAlert.arrivalBusStopNm)
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
    }
}

