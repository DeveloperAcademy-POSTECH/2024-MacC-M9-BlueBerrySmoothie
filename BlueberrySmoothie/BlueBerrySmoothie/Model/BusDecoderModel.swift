//
//  DummyModel.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/30/24.
//
import Foundation

// API 응답을 위한 모델
struct BusResponse: Codable {
    let response: ResponseBody
    
    struct ResponseBody: Codable {
        let body: Body
        
        struct Body: Codable {
            let items: Items?
            
            struct Items: Codable {
                let item: [Bus]? // Bus 객체 배열
            }
        }
    }
}

// API 응답을 위한 모델
struct BusResponsenotarray: Codable {
    let response: ResponseBody
    
    struct ResponseBody: Codable {
        let body: Body
        
        struct Body: Codable {
            let items: Items?
            
            struct Items: Codable {
                let item: Bus? // Bus 객체 배열
            }
        }
    }
}
