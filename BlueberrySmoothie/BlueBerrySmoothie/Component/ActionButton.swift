//
//  ActionButton.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI

struct startButtonUI: View {


    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color.gray4)
                .cornerRadius(10.0)
            
            Text("시작하기")
                .font(.caption1)
                .foregroundColor(.white)
                .padding(20)
        }
        .fixedSize(horizontal: false, vertical: true)
    }}

