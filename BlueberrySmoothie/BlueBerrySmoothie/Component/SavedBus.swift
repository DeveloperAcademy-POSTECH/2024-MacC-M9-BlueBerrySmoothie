//
//  SavedBus.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI

struct SavedBus: View {
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
                Spacer()
                HStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(Color(white: 238 / 255))
                            .cornerRadius(20)
                            .frame(width: 48, height: 24)
                            
                        Text("207")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 170 / 255))

                    }
                    Spacer()
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color(white: 212 / 255))
                }
                .padding(.bottom, 4)
                
                HStack {
                    Text("시외버스 터미널")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                }
                .padding(.bottom, 4)
                
                HStack {
                    Text("엄마보러가자")
                        .font(.system(size: 16))
                        .foregroundColor(Color(white: 170 / 255))
                    Spacer()
                }
                .padding(.bottom, 4)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12.0))
                    Text("3 정류장 전 알람")
                        .font(.system(size: 14.0))
                    Spacer()
                }
                .foregroundColor(Color(white: 128 / 255))
                
                Spacer()
            }
            .padding(.top, 12)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    SavedBus()
}
