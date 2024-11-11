//
//  BusLocationModel.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 11/11/24.
//

import Foundation

struct NowBusLocation: Codable, Identifiable {
    let id = UUID()
    let gpslati: String
    let gpslong: String
    let nodeid: String
    let nodenm: String
    let nodeord: Int
    let routenm: Int
    let routetp: String
    let vehicleno: String

    // 커스텀 디코딩 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // gpslati를 Double 또는 String으로 디코딩
        if let gpslatiValue = try? container.decode(Double.self, forKey: .gpslati) {
            gpslati = String(gpslatiValue)
        } else {
            gpslati = try container.decode(String.self, forKey: .gpslati)
        }

        // gpslong를 Double 또는 String으로 디코딩
        if let gpslongValue = try? container.decode(Double.self, forKey: .gpslong) {
            gpslong = String(gpslongValue)
        } else {
            gpslong = try container.decode(String.self, forKey: .gpslong)
        }

        nodeid = try container.decode(String.self, forKey: .nodeid)
        nodenm = try container.decode(String.self, forKey: .nodenm)
        nodeord = try container.decode(Int.self, forKey: .nodeord)
        routenm = try container.decode(Int.self, forKey: .routenm)
        routetp = try container.decode(String.self, forKey: .routetp)
        vehicleno = try container.decode(String.self, forKey: .vehicleno)
    }
}
