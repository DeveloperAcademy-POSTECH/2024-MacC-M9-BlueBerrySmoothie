//
////
////  NowBusLocationResponse.swift
////  BlueBerrySmoothie
////
////  Created by 문재윤 on 11/7/24.
////
//
//
//import Foundation
//import SwiftUI
//
//
//struct BusLocationListView: View {
//    @StateObject private var NowviewModel = NowBusLocationViewModel()
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if let closestBus = NowviewModel.closestBusLocation {
//                    VStack(alignment: .leading) {
//                        Text(closestBus.nodenm)
//                            .font(.headline)
//                        Text("차량번호: \(closestBus.vehicleno)")
//                        Text("위도: \(closestBus.gpslati), 경도: \(closestBus.gpslong)")
//                        Text("노선: \(closestBus.routenm), 순서: \(closestBus.nodeord)")
//                        Text("노선: \(closestBus)")
//                    }
//                    .padding(.vertical, 5)
//                    .navigationTitle("가장 가까운 버스 위치")
//                } else {
//                    Text("가장 가까운 버스 위치를 찾고 있습니다...")
//                }
//            }
//            .onAppear {
//                NowviewModel.fetchBusLocationData(cityCode: 21, routeId: "BSB5200043000")
//            }
//        }
//    }
//}
//
//
//struct NowBusLocationListView_Previews: PreviewProvider {
//    static var previews: some View {
//        BusLocationListView()
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//import Foundation
//import SwiftUI
//import CoreLocation
//import Combine
//
//class NowBusLocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
//    @Published var NowbusLocations: [NowBusLocation] = []
//    @Published var closestBusLocation: NowBusLocation?
//    
//    private var cancellables = Set<AnyCancellable>()
//    private var locationManager = CLLocationManager()
//    private var userLocation: CLLocation?
//    
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        
//        fetchBusLocationData(cityCode: 21, routeId: "BSB5200043000")
//    }
//    
//    // CLLocationManagerDelegate 메서드 - 사용자 위치 업데이트 시 호출
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        userLocation = location
//        findClosestBusLocation()
//    }
//    
//    // API를 호출하여 버스 위치 데이터를 가져옴
//    func fetchBusLocationData(cityCode: Int, routeId: String) {
//        fetchNowBusLocationData(cityCode: cityCode, routeId: routeId) { [weak self] locations in
//            DispatchQueue.main.async {
//                self?.NowbusLocations = locations
//                self?.findClosestBusLocation() // 데이터 가져온 후 가장 가까운 버스 위치 계산
//            }
//        }
//    }
//    
//    // 사용자 위치와 가장 가까운 버스 위치를 찾음
//    private func findClosestBusLocation() {
//        guard let userLocation = userLocation else { return }
//        
//        closestBusLocation = NowbusLocations.min(by: { bus1, bus2 in
//            let busLocation1 = CLLocation(latitude: Double(bus1.gpslati) ?? 0, longitude: Double(bus1.gpslong) ?? 0)
//            let busLocation2 = CLLocation(latitude: Double(bus2.gpslati) ?? 0, longitude: Double(bus2.gpslong) ?? 0)
//            
//            return userLocation.distance(from: busLocation1) < userLocation.distance(from: busLocation2)
//        })
//    }
//}
//
//
//// API 응답을 위한 모델
//struct NowBusLocationResponse: Codable {
//    let response: ResponseBody
//    
//    struct ResponseBody: Codable {
//        let body: Body
//        
//        struct Body: Codable {
//            let items: Items?
//            
//            struct Items: Codable {
//                let item: [NowBusLocation]? // BusLocation 객체 배열
//            }
//        }
//    }
//}
//
//// 단일 객체 응답을 위한 모델
//struct NowBusLocationResponseNotArray: Codable {
//    let response: ResponseBody
//    
//    struct ResponseBody: Codable {
//        let body: Body
//        
//        struct Body: Codable {
//            let items: Items?
//            
//            struct Items: Codable {
//                let item: NowBusLocation? // 단일 BusLocation 객체
//            }
//        }
//    }
//}
//
//struct NowBusLocation: Codable, Identifiable {
//    let id = UUID()
//    let gpslati: String
//    let gpslong: String
//    let nodeid: String
//    let nodenm: String
//    let nodeord: Int
//    let routenm: Int
//    let routetp: String
//    let vehicleno: String
//    
//    // 커스텀 디코딩 구현
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        // gpslati를 Double 또는 String으로 디코딩
//        if let gpslatiValue = try? container.decode(Double.self, forKey: .gpslati) {
//            gpslati = String(gpslatiValue)
//        } else {
//            gpslati = try container.decode(String.self, forKey: .gpslati)
//        }
//        
//        // gpslong를 Double 또는 String으로 디코딩
//        if let gpslongValue = try? container.decode(Double.self, forKey: .gpslong) {
//            gpslong = String(gpslongValue)
//        } else {
//            gpslong = try container.decode(String.self, forKey: .gpslong)
//        }
//        
//        nodeid = try container.decode(String.self, forKey: .nodeid)
//        nodenm = try container.decode(String.self, forKey: .nodenm)
//        nodeord = try container.decode(Int.self, forKey: .nodeord)
//        routenm = try container.decode(Int.self, forKey: .routenm)
//        routetp = try container.decode(String.self, forKey: .routetp)
//        vehicleno = try container.decode(String.self, forKey: .vehicleno)
//    }
//}
//
//
//// BusLocation 데이터를 가져오는 함수
//func fetchNowBusLocationData(cityCode: Int, routeId: String, completion: @escaping ([NowBusLocation]) -> Void) {
//    do {
//        print("Starting fetchBusLocationData with cityCode: \(cityCode), routeId: \(routeId)")
//        
//        guard let serviceKey = getAPIKey() else {
//            print("API Key Error: Invalid API Key")
//            throw APIError.invalidAPI
//        }
//        
//        let urlString = "http://apis.data.go.kr/1613000/BusLcInfoInqireService/getRouteAcctoBusLcList?serviceKey=\(serviceKey)&_type=json&cityCode=\(cityCode)&routeId=\(routeId)&numOfRows=9999&pageNo=1"
//        print("Request URL: \(urlString)")
//        
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            completion([]) // URL이 유효하지 않으면 빈 배열 반환
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Network error: \(error)")
//                completion([]) // 네트워크 오류 시 빈 배열 반환
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received from API")
//                completion([]) // 데이터가 없는 경우 빈 배열 반환
//                return
//            }
//            
//            // 배열 형태로 디코딩 시도
//            do {
//                let response = try JSONDecoder().decode(NowBusLocationResponse.self, from: data)
//                if let items = response.response.body.items?.item {
////                    print("Decoded array of BusLocation items: \(items)")
//                    DispatchQueue.main.async {
//                        completion(items) // BusLocation 객체 배열 반환
//                    }
//                    return
//                }
//            } catch {
//                print("Array decoding failed: \(error)")
//            }
//            
//            // 단일 객체로 디코딩 시도
//            do {
//                let singleObjectResponse = try JSONDecoder().decode(NowBusLocationResponseNotArray.self, from: data)
//                if let singleBusLocation = singleObjectResponse.response.body.items?.item {
////                    print("Decoded single BusLocation item: \(singleBusLocation)")
//                    DispatchQueue.main.async {
//                        completion([singleBusLocation]) // 단일 BusLocation 객체 배열로 반환
//                    }
//                    return
//                }
//            } catch {
//                print("Single object decoding failed: \(error)")
//            }
//            
//            // 디코딩 실패 시 빈 배열 반환
//            DispatchQueue.main.async {
//                print("Decoding failed, returning empty array")
//                completion([]) // BusLocation 객체 없음
//            }
//        }.resume() // 데이터 요청 시작
//    } catch {
//        print("API serviceKey Error: \(error)")
//    }
//}
