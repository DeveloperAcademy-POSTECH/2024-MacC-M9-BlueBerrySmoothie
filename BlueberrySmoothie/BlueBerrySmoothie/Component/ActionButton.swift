//
//  ActionButton.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI

struct ActionButton: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 104.0 / 255.0, green: 144.0 / 255.0, blue: 1.0))
                .cornerRadius(10.0)
            
            Text("시작하기")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(20)
        }
        .fixedSize(horizontal: false, vertical: true)
    }}

#Preview {
    ActionButton()
}
