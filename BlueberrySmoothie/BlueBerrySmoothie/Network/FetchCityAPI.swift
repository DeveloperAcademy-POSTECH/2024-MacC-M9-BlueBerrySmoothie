//
//  FetchCityAPI.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 10/31/24.
//

import Foundation

// View 외부에 fetchCityData 함수 정의
func fetchCityData(completion: @escaping ([City]) -> Void) {
    guard let url = URL(string: "http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getCtyCodeList?serviceKey=B%2FSwHGsQuvan%2F%2Fs6M6QvZooclQm9QpSHe%2BqbWjT4xPwDgHNXOES93T9i1%2BDKEJPWfCgcTf12X64bS9A42fFRkA%3D%3D&_type=json") else { return }
    
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data else { return }
        
        if let response = try? JSONDecoder().decode(CityResponse.self, from: data) {
            DispatchQueue.main.async {
                completion(response.response.body.items.item)
            }
        }
    }.resume()
}
