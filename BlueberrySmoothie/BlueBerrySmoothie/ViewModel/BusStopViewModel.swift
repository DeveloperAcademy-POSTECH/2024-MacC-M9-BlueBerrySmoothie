////
////  BusStopViewModel.swift
////  BlueBerrySmoothie
////
////  Created by Yeji Seo on 10/31/24.
////

import Foundation

class BusStopViewModel: ObservableObject {
    @Published var busStopList: [BusStop] = []
    
    var networkManager = NetworkManager()

    func getBusStopData(cityCode: Int, routeId: String) async {
        do {
            let data = try await networkManager.getBusStopData(cityCode: cityCode, routeId: routeId)
            DispatchQueue.main.async {
                self.busStopList = data
            }
        } catch {
            print("Error calling getBusStopData API in busStopViewModel")
        }
    }
}
