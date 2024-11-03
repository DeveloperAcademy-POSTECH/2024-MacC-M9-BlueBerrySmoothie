//
//  BusStopDecoderModel.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/31/24.
//

import Foundation

struct BusStopResponse: Codable {
    let response: ResponseBody
    
    struct ResponseBody: Codable {
        let body: Body
        
        struct Body: Codable {
            let items: Items?
            let numOfRows, pageNo, totalCount: Int
            
            struct Items: Codable {
                let item: [BusStop]?
            }
        }
    }
}
