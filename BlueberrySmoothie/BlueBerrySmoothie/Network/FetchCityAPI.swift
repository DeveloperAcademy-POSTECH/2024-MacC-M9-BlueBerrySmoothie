//
//  FetchCityAPI.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 10/31/24.
//

import Foundation

// View 외부에 fetchCityData 함수 정의
func fetchCityData(completion: @escaping ([City]) -> Void) {
    
    do{
        guard let serviceKey = getAPIKey() else {
            throw APIError.invalidAPI
        }
        
        guard let url = URL(string: "http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getCtyCodeList?serviceKey=\(serviceKey)&_type=json") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            
            if let response = try? JSONDecoder().decode(CityResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(response.response.body.items.item)
                }
            }
        }.resume()
    } catch {
        
        print("API serviceKey Error")
    }
}
