//
//  AppView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/24/24.
//


import SwiftUI

struct AppView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
            if hasSeenOnboarding {
                MainView()  // 온보딩을 본 후에는 MainView로 이동
            } else {
                OnboardingView()  // 온보딩을 아직 보지 않았다면 OnboardingView로 이동
            }
    }
}
