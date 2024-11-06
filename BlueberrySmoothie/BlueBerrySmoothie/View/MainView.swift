//
//  MainView.swift
//  BlueBerrySmoothie
//
//  Created by 문호 on 11/4/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            HStack {
                Text("버스 알람")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Text("추가")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 104 / 255, green: 144 / 255, blue: 255 / 255))
            }
            .padding(.bottom, 26)
            
            SavedBus()
                .padding(.bottom, 8)
            SavedBus()
            
            Spacer()
            
            ActionButton()
        }
        .padding(20)
    }
}

#Preview {
    MainView()
}
