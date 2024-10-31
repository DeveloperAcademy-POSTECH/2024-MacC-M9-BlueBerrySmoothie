//
//  BusStopModel.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/31/24.
//

import Foundation

// MARK: - Items
struct BusStopList_Items: Codable {
    let item: [BusStop]
}

// MARK: - BusStop
struct BusStop: Codable, Identifiable, Hashable {
    let id = UUID() // 각 버스 객체에 대한 고유 ID
    let routeid: String
    let nodeid: String
    let nodenm: String
    let nodeno: Int?
    let nodeord: Int
    let gpslati: Double
    let gpslong: Double
    let updowncd: Int
    
    enum CodingKeys: String, CodingKey {
            case routeid, nodeid, nodenm, nodeno, nodeord, gpslati, gpslong, updowncd
        }
        
        // nodeno의 커스텀 디코딩 구현
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            routeid = try container.decode(String.self, forKey: .routeid)
            nodeid = try container.decode(String.self, forKey: .nodeid)
            nodenm = try container.decode(String.self, forKey: .nodenm)
            nodeord = try container.decode(Int.self, forKey: .nodeord)
            gpslati = try container.decode(Double.self, forKey: .gpslati)
            gpslong = try container.decode(Double.self, forKey: .gpslong)
            updowncd = try container.decode(Int.self, forKey: .updowncd)

            // `nodeno`가 String 또는 Int일 수 있으므로, String으로 먼저 시도한 뒤 실패하면 Int로 처리
            if let nodenoString = try? container.decode(String.self, forKey: .nodeno),
               let nodenoInt = Int(nodenoString) {
                nodeno = nodenoInt
            } else {
                nodeno = try? container.decode(Int.self, forKey: .nodeno)
            }
        }
}
