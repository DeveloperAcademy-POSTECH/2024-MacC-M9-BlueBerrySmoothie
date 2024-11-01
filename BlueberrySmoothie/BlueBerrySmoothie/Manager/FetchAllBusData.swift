//
//  FetchAllBud.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/1/24.
//


// 전체 버스 데이터를 불러오는 함수
func fetchAllBusData(citycode: Int, completion: @escaping ([Bus]) -> Void) {
    fetchBusData(citycode: citycode, routeNo: "") { fetchedBuses in
        completion(fetchedBuses)
    }
}
