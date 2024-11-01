//
//  filter.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/1/24.
//

import Foundation

// 입력된 노선 번호에 따라 버스를 필터링하는 함수
func filterBuses(by routeNo: String, from allBuses: [Bus]) -> [Bus] {
    if routeNo.isEmpty {
        return allBuses // 입력이 없으면 전체 목록 반환
    } else {
        return allBuses.filter { $0.routeno.contains(routeNo) }
            .sorted {
                let firstLength = $0.routeno.count
                let secondLength = $1.routeno.count
                if firstLength == secondLength {
                    return $0.routeno < $1.routeno
                }
                return firstLength < secondLength
            }
    }
}
