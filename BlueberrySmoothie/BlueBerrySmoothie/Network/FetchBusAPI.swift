//
//  DummyNetwork.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/30/24.
//

import Foundation

// 버스 데이터를 가져오는 함수
func fetchBusData(citycode: Int, routeNo: String, completion: @escaping ([Bus]) -> Void) {
    let serviceKey = "B%2FSwHGsQuvan%2F%2Fs6M6QvZooclQm9QpSHe%2BqbWjT4xPwDgHNXOES93T9i1%2BDKEJPWfCgcTf12X64bS9A42fFRkA%3D%3D"
    let urlString = "http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getRouteNoList?serviceKey=\(serviceKey)&_type=json&cityCode=\(citycode)&routeNo=\(routeNo)&numOfRows=9999&pageNo=1"
    
    guard let url = URL(string: urlString) else {
        completion([]) // Return empty array for invalid URL
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data else {
            completion([]) // Return empty array if no data
            return
        }
        
        // Try to decode as BusResponse first
        do {
            let response = try JSONDecoder().decode(BusResponse.self, from: data)
            if let items = response.response.body.items?.item {
                DispatchQueue.main.async {
                    print("여러개") // Multiple bus objects found
                    completion(items) // Return array of Bus objects
                }
                return // Exit the function after a successful completion
            }
        } catch {
            print("Array decoding failed: \(error)")
        }
        
        // If array decoding failed, try to decode as BusResponsenotarray
        do {
            let singleObjectResponse = try JSONDecoder().decode(BusResponsenotarray.self, from: data)
            if let singleBus = singleObjectResponse.response.body.items?.item {
                DispatchQueue.main.async {
                    print("한개") // Single bus object found
                    completion([singleBus]) // Return an array containing the single Bus object
                }
                return // Exit the function after a successful completion
            }
        } catch {
            print("Single object decoding failed: \(error)")
        }
        
        // If both decodings failed
        DispatchQueue.main.async {
            completion([]) // Return empty array if no items found in both attempts
        }
    }.resume() // Start the data task
}
