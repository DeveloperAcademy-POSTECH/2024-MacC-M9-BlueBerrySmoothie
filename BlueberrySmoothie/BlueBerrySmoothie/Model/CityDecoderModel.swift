//
//  CityDecoderModel.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 10/31/24.
//
import Foundation


struct CityResponse: Codable {
    let response: ResponseBody
    
    struct ResponseBody: Codable {
        let body: Body
        
        struct Body: Codable {
            let items: Items
        }
        
        struct Items: Codable {
            let item: [City]
        }
    }
}
