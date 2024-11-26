//
//  SplashView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/24/24.
//


import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            // 스플래시 화면 후 보여질 메인 화면
            AppView()
        } else {
            // 스플래시 화면
                Image("Splash")
                    .frame(width: 300)
                    .padding(.bottom, 100)

            .onAppear {
                // 3초 후에 메인 화면으로 전환
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
