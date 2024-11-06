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
                HStack(alignment: .bottom) {
                        Text("출근하는 거 힘들다")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 128 / 255))
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.system(size: 24))
                        .foregroundColor(Color(white: 212 / 255))
                        .padding(.vertical, 20)
                }
                HStack {
                    Text("207")
                        .font(.system(size: 20, weight: .regular))
                    Text("포스텍")
                        .font(.system(size: 20, weight: .regular))
                    Spacer()
                }
                .padding(.bottom, 4)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255))
                    Text("3 정류장 전 알람")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255))
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 2, height: 12)
                        .background(Color(white: 238 / 255))
                    
                    Text("행정복지센터")
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

#Preview {
    SavedBus()
}
