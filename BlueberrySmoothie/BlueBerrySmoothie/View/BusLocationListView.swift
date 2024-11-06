import Foundation
import SwiftUI

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

struct NowBusLocation: Codable, Identifiable {
    let id = UUID()
    let gpslati: String
    let gpslong: String
    let nodeid: String
    let nodenm: String
    let nodeord: Int
    let routenm: Int
    let routetp: String
    let vehicleno: String
    
    // 커스텀 디코딩 구현
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // gpslati를 Double 또는 String으로 디코딩
        if let gpslatiValue = try? container.decode(Double.self, forKey: .gpslati) {
            gpslati = String(gpslatiValue)
        } else {
            gpslati = try container.decode(String.self, forKey: .gpslati)
        }
        
        // gpslong를 Double 또는 String으로 디코딩
        if let gpslongValue = try? container.decode(Double.self, forKey: .gpslong) {
            gpslong = String(gpslongValue)
        } else {
            gpslong = try container.decode(String.self, forKey: .gpslong)
        }
        
        nodeid = try container.decode(String.self, forKey: .nodeid)
        nodenm = try container.decode(String.self, forKey: .nodenm)
        nodeord = try container.decode(Int.self, forKey: .nodeord)
        routenm = try container.decode(Int.self, forKey: .routenm)
        routetp = try container.decode(String.self, forKey: .routetp)
        vehicleno = try container.decode(String.self, forKey: .vehicleno)
    }
}


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



//struct BusLocationListView: View {
//    @StateObject private var viewModel = BusLocationViewModel()
//
//    var body: some View {
//        NavigationView {
//            Button(action: { viewModel.fetchBusLocationData(cityCode: 21, routeId: "BSB5200043000")
//                for i in viewModel.busLocations {print(i,"ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ")}}, label: {Text("zz")})
//            List(viewModel.busLocations) { location in
//                VStack(alignment: .leading) {
//                    Text(location.nodenm)
//                        .font(.headline)
//                    Text("Vehicle No: \(location.vehicleno)")
//                    Text("Latitude: \(location.gpslati), Longitude: \(location.gpslong)")
//                    Text("Route: \(location.routenm), Order: \(location.nodeord)")
//                }
//                .padding(.vertical, 5)
//            }
//            .navigationTitle("Bus Locations")
//            .onAppear {
//                viewModel.fetchBusLocationData(cityCode: 21, routeId: "BSB5200043000")
//            }
//        }
//    }
//}
//


struct BusLocationListView: View {
    @StateObject private var NowviewModel = NowBusLocationViewModel()

    var body: some View {
        NavigationView {
            VStack {
                
                List(NowviewModel.NowbusLocations) { location in
                    VStack(alignment: .leading) {
                        Text(location.nodenm)
                            .font(.headline)
                        Text("차량번호: \(location.vehicleno)")
                        Text("위도: \(location.gpslati), 경도: \(location.gpslong)")
                        Text("노선: \(location.routenm), 순서: \(location.nodeord)")
                    }
                    .padding(.vertical, 5)
                }
                .navigationTitle("버스 위치")
                .onAppear {
                    // 처음 화면이 보일 때 데이터를 가져오기
                    NowviewModel.fetchBusLocationData(cityCode: 21, routeId: "BSB5200043000")
                }
            }
        }
    }
}

struct NowBusLocationListView_Previews: PreviewProvider {
    static var previews: some View {
        BusLocationListView()
    }
}


import Foundation
import Combine

class NowBusLocationViewModel: ObservableObject {
    @Published var NowbusLocations: [NowBusLocation] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        BlueBerrySmoothie.fetchNowBusLocationData(cityCode: 21, routeId: "BSB5200043000") { [weak self] locations in
            self?.NowbusLocations = locations
        }
    }
    
    func fetchBusLocationData(cityCode: Int, routeId: String) {
        BlueBerrySmoothie.fetchNowBusLocationData(cityCode: cityCode, routeId: routeId) { [weak self] locations in
            DispatchQueue.main.async {
                self?.NowbusLocations = locations
            }
        }
    }
}
