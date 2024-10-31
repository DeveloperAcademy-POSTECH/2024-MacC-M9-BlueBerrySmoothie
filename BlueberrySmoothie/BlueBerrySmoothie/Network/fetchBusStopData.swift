//
//  FetchBusStop.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/31/24.
//

import Foundation



class NetworkManager: ObservableObject {
    
    // 버스 정류장 데이터를 가져오는 함수
    func getBusStopData(cityCode: Int, routeId: String) async throws -> [BusStop] {
        // BusStopResponse를 통해 모든 데이터를 가져온 뒤 필요한 배열만 추출하여 반환
        let response: BusStopResponse = try await fetchBusStopData(cityCode: cityCode, routeId: routeId)
        return response.response.body.items?.item ?? []
    }
    
    // fetchBusStopData를 제네릭에서 BusStopResponse로 변경
    private func fetchBusStopData(cityCode: Int, routeId: String) async throws -> BusStopResponse {
        let serviceKey = "B%2FSwHGsQuvan%2F%2Fs6M6QvZooclQm9QpSHe%2BqbWjT4xPwDgHNXOES93T9i1%2BDKEJPWfCgcTf12X64bS9A42fFRkA%3D%3D"
        let urlString = "http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getRouteAcctoThrghSttnList?serviceKey=\(serviceKey)&_type=json&cityCode=\(cityCode)&routeId=\(routeId)&numOfRows=999"
        
        guard let url = URL(string: urlString) else {
            print("APIError.invalidURL")
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.requestFailed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            // JSONDecoder를 통해 BusStopResponse로 디코딩
            return try JSONDecoder().decode(BusStopResponse.self, from: data)
        } catch {
            // 디코딩 에러 확인 및 처리
            if let decodingError = error as? DecodingError {
                print("Decoding error: \(decodingError)")
                throw APIError.decodingError(underlyingError: decodingError)
            } else {
                throw APIError.dataLoadingError(underlyingError: error)
            }
        }
    }
}
