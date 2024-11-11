//
//  BusLocationDecoderModel.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 11/11/24.
//

import Foundation

// API 응답을 위한 모델
struct NowBusLocationResponse: Codable {
    let response: ResponseBody

    struct ResponseBody: Codable {
        let body: Body

        struct Body: Codable {
            let items: Items?

            struct Items: Codable {
                let item: [NowBusLocation]? // BusLocation 객체 배열
            }
        }
    }
}

// 단일 객체 응답을 위한 모델
struct NowBusLocationResponseNotArray: Codable {
    let response: ResponseBody

    struct ResponseBody: Codable {
        let body: Body

        struct Body: Codable {
            let items: Items?

            struct Items: Codable {
                let item: NowBusLocation? // 단일 BusLocation 객체
            }
        }
    }
}
