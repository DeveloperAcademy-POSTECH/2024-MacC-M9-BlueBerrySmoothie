////
////  BusStopViewModel.swift
////  BlueBerrySmoothie
////
////  Created by Yeji Seo on 10/31/24.
////

import Foundation

class BusStopViewModel: ObservableObject {
    @Published var busStopList: [BusStop] = []
    @Published var maxUpwardNodeord: Int?
   
    
    var networkManager = NetworkManager()

    func getBusStopData(cityCode: Int, routeId: String) async {
        do {
            let data = try await networkManager.getBusStopData(cityCode: cityCode, routeId: routeId)
            DispatchQueue.main.async {
                self.busStopList = data
                self.maxUpwardNodeord = self.busStopList.filter({ $0.updowncd == 0 }).map({ $0.nodeord }).max()
                print(self.maxUpwardNodeord)
            }
        } catch {
            print("Error calling getBusStopData API in busStopViewModel")
        }
    }
}
