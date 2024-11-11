//
//  FetchBusLocationAPI.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 11/11/24.
//

import Foundation


// BusLocation 데이터를 가져오는 함수
func fetchNowBusLocationData(cityCode: Int, routeId: String, completion: @escaping ([NowBusLocation]) -> Void) {
    do {
        print("Starting fetchBusLocationData with cityCode: \(cityCode), routeId: \(routeId)")

        guard let serviceKey = getAPIKey() else {
            print("API Key Error: Invalid API Key")
            throw APIError.invalidAPI
        }

        let urlString = "http://apis.data.go.kr/1613000/BusLcInfoInqireService/getRouteAcctoBusLcList?serviceKey=\(serviceKey)&_type=json&cityCode=\(cityCode)&routeId=\(routeId)&numOfRows=9999&pageNo=1"
        print("Request URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([]) // URL이 유효하지 않으면 빈 배열 반환
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion([]) // 네트워크 오류 시 빈 배열 반환
                return
            }

            guard let data = data else {
                print("No data received from API")
                completion([]) // 데이터가 없는 경우 빈 배열 반환
                return
            }

            // 배열 형태로 디코딩 시도
            do {
                let response = try JSONDecoder().decode(NowBusLocationResponse.self, from: data)
                if let items = response.response.body.items?.item {
//                    print("Decoded array of BusLocation items: \(items)")
                    DispatchQueue.main.async {
                        completion(items) // BusLocation 객체 배열 반환
                    }
                    return
                }
            } catch {
                print("Array decoding failed: \(error)")
            }

            // 단일 객체로 디코딩 시도
            do {
                let singleObjectResponse = try JSONDecoder().decode(NowBusLocationResponseNotArray.self, from: data)
                if let singleBusLocation = singleObjectResponse.response.body.items?.item {
//                    print("Decoded single BusLocation item: \(singleBusLocation)")
                    DispatchQueue.main.async {
                        completion([singleBusLocation]) // 단일 BusLocation 객체 배열로 반환
                    }
                    return
                }
            } catch {
                print("Single object decoding failed: \(error)")
            }

            // 디코딩 실패 시 빈 배열 반환
            DispatchQueue.main.async {
                print("Decoding failed, returning empty array")
                completion([]) // BusLocation 객체 없음
            }
        }.resume() // 데이터 요청 시작
    } catch {
        print("API serviceKey Error: \(error)")
    }
}
