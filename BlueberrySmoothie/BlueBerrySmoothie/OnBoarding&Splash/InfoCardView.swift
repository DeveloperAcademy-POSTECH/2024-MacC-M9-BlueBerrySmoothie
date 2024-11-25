//
//  InfoCardView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/25/24.
//


import SwiftUI

struct InfoCardView: View {
    let icon: String
    let title: String
    let descriptions: [String]
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 0) {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .clipped() // 프레임에 맞게 이미지를 잘라냄
                    .padding(.leading, 20)
            }
            .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.title3)
                
                ForEach(descriptions, id: \.self) { description in
                    Text(description)
                        .foregroundStyle(.gray3)
                }
            }
            Spacer()
        }
        .padding(.vertical, 20)
        .background(
            Color.gray7
                .cornerRadius(20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray5, lineWidth: 1)
        )
    }
        
}
