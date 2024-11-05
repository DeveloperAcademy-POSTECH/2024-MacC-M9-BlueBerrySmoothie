
//import SwiftUI
//
//struct BusStopListView: View {
//    let busStops: [BusStopLocal] // 정류소 정보 배열
//    let alert: Alert // 관련된 알림 정보
//    
//    @State private var isAlertEnabled: Bool = false // 스위치 상태 관리
//    
//    var body: some View {
//        VStack {
//            VStack {
//                VStack{
//                    HStack{
//                        Text("\(alert.busNo)")
//                        Image(systemName: "suit.diamond.fill")
//                            .font(.system(size: 10))
//                            .foregroundStyle(.midbrand)
//                        Text("\(alert.alertLabel)")
//                        Spacer()
//                    }
//                    .font(.title3)
//                    .foregroundStyle(.gray2)
//                    HStack {
//                        Image(systemName: "bell.circle")
//                            .font(.system(size: 20))
//                            .foregroundStyle(.midbrand)
//                        Text("운촌")
//                        Toggle(isOn: $isAlertEnabled) {
//                            //                        Text("알림 켜기") // 스위치 레이블
//                        }
//                        .toggleStyle(SwitchToggleStyle(tint: .brand))
//                    }
//                    .font(.title)
//                    HStack{
//                        Text("12정류장 후 알림")
//                            .foregroundStyle(.gray3)
//                        Spacer()
//                    }
//                    
//                }
//                .padding(.horizontal, 20)
//                .padding(.top)
//                .padding(.bottom, 28)
//            }
//            .background(.white)
//            
//            
//            
//            ScrollView(showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 0) {
//                    ForEach(busStops, id: \.id) { busStop in
//                        
//                        
//                        HStack{
//                            //                            Image(systemName: "dot.circle")
//                            VStack {
//                                
//                                Rectangle()
//                                    .frame(width: 1) // 선의 너비
//                                    .foregroundStyle(.gray5)
//                                Image(systemName: "circle.fill")
//                                    .foregroundStyle(.brand)
//                                    .font(.system(size: 5))
//                                    .padding(.vertical, 2)
//                                Rectangle()
//                                    .frame(width: 1) // 선의 너비
//                                    .foregroundStyle(.gray5)
//                            }
//                            .foregroundStyle(.gray)
//                            .padding(.leading, 40)
//                            
//                            
//                            Text(busStop.nodenm) // 정류소 이름 표시
//                                .padding(.leading, 25)
//                                .font(.system(size: 16))
//                            Spacer()
//                        }
//                        .frame(height: 60)
//                    }
//                    Spacer()
//                }
//            }
//        }.navigationTitle("출근하기")
//            .background(.doublelightbrand)
//    }
//}
//
//
//
//
