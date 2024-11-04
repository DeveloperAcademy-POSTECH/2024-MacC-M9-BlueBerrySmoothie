//
//  ContentView.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: SelectCityView()) {
                    HStack {
                        Image(systemName: "location.fill") // 도시 선택 심볼
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Select City")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }
                
                NavigationLink(destination: ContentView()) {
                    HStack {
                        Image(systemName: "alarm.fill") // 알람 시작 심볼
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Start Alarm")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Main Menu")
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
