//
//  BlueBerrySmoothieApp.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/30/24.
//

import SwiftUI

@main
struct BlueBerrySmoothieApp: App {
    @StateObject private var busStopViewModel = BusStopViewModel()
    
    var body: some Scene {
        WindowGroup {
            SelectCityView()
                .environmentObject(busStopViewModel)
        }
    }
}
