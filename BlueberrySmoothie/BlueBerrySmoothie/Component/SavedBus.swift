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
                .foregroundColor(Color.white)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.brand, lineWidth: 2)
                }
            VStack {
                HStack(alignment: .bottom) {
                        Text("출근하는 거 힘들다")
                        .font(.regular12)
                        .foregroundColor(Color.brand)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.regular20)
                        .foregroundColor(Color.gray4)
                        .padding(.vertical, 20)
                }
                HStack {
                    Text("207")
                        .font(.regular20)
                    Text("포스텍")
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
                    Text("3 정류장 전 알람")
                        .font(.regular14)
                        .foregroundColor(Color.brand)
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 2, height: 12)
                        .background(Color.gray5)
                    
                    Text("행정복지센터")
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

#Preview {
    SavedBus()
}
