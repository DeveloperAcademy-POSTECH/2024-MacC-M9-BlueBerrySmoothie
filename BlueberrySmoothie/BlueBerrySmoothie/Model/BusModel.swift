//
//  BusModel.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 10/31/24.
import Foundation

// 버스 정보를 위한 모델
struct Bus: Codable, Identifiable {
    let id = UUID() // 각 버스 객체에 대한 고유 ID
    let routeno: String // 노선 번호
    let routeid: String // 노선 ID
    let startnodenm: String // 출발 정류장 이름
    let endnodenm: String // 도착 정류장 이름
    let startvehicletime: String // 출발 시간
    let endvehicletime: String // 도착 시간
    let routetp: String // 노선 타입
    
    enum CodingKeys: String, CodingKey {
        case routeno, routeid, startnodenm, endnodenm, startvehicletime, endvehicletime, routetp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // routeno가 Int 또는 String인 경우를 처리
        if let routenoInt = try? container.decode(Int.self, forKey: .routeno) {
            routeno = String(routenoInt) // Int를 String으로 변환
        } else {
            routeno = (try? container.decode(String.self, forKey: .routeno)) ?? "알 수 없음" // String으로 디코딩 또는 기본값
        }
        
        // startvehicletime 처리
        if let startvehicletimeInt = try? container.decode(Int.self, forKey: .startvehicletime) {
            startvehicletime = String(startvehicletimeInt) // Int를 String으로 변환
        } else {
            startvehicletime = (try? container.decode(String.self, forKey: .startvehicletime)) ?? "알 수 없음" // 기본값
        }
        
        // endvehicletime 처리
        if let endvehicletimeInt = try? container.decode(Int.self, forKey: .endvehicletime) {
            endvehicletime = String(endvehicletimeInt) // Int를 String으로 변환
        } else {
            endvehicletime = (try? container.decode(String.self, forKey: .endvehicletime)) ?? "알 수 없음" // 기본값
        }
        
        routeid = (try? container.decode(String.self, forKey: .routeid)) ?? "알 수 없음"
        startnodenm = (try? container.decode(String.self, forKey: .startnodenm)) ?? "알 수 없음"
        endnodenm = (try? container.decode(String.self, forKey: .endnodenm)) ?? "알 수 없음"
        routetp = (try? container.decode(String.self, forKey: .routetp)) ?? "알 수 없음"
    }
    
    // 사용자 정의 이니셜라이저
        init(
            routeno: String = "알 수 없음",
            routeid: String = "알 수 없음",
            startnodenm: String = "알 수 없음",
            endnodenm: String = "알 수 없음",
            startvehicletime: String = "알 수 없음",
            endvehicletime: String = "알 수 없음",
            routetp: String = "알 수 없음"
        ) {
            self.routeno = routeno
            self.routeid = routeid
            self.startnodenm = startnodenm
            self.endnodenm = endnodenm
            self.startvehicletime = startvehicletime
            self.endvehicletime = endvehicletime
            self.routetp = routetp
        }

}
