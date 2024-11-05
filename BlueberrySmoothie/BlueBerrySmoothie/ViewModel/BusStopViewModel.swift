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
            print(routeId)
            print("받아온 데이터: \(data)") // 데이터 출력
            DispatchQueue.main.async {
                self.busStopList = data
            
            }
        } catch {
            print("Error calling getBusStopData API in busStopViewModel")
        }
    }
}
