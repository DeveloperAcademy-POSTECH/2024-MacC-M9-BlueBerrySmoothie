////
////  UsingAlertView.swift
////  BlueBerrySmoothie
////
////  Created by 원주연 on 11/4/24.
////
//
//import SwiftUI
//
//struct UsingAlertViewDaisy: View {
//    // NotificationManager 인스턴스 감지
//    @ObservedObject var notificationManager = NotificationManager.instance
//    
//    // EndView로의 이동 상태를 관리하는 변수
//    @State private var navigateToEndView = false
//    
//    let alert: Alert
//    
//    var body: some View {
//        ZStack {
//            Text("Using Alert View")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            
//            // 새로운 오버레이 뷰
//            if notificationManager.notificationReceived {
//                AfterAlertView()
//            }
//            
////            // EndView로의 네비게이션
////            NavigationLink(destination: EndViewDaisy(alert: alert), isActive: $navigateToEndView) {
////                EmptyView()
////            }
//        }
////        .onAppear{
////            if notificationManager.notificationReceived == true {
////                AfterAlertView()
////            }
////        }
//        .edgesIgnoringSafeArea(.all) // 전체 화면에 적용
//    }
//    
//    @ViewBuilder
//    func AfterAlertView() -> some View {
//        VStack {
//            Image("AfterAlertImg")
//                .padding()
//            
//            Button(action: {
//                notificationManager.notificationReceived = false // 오버레이 닫기
//                alert.isActivating = false
//                print(alert.busNumber)
//                print(alert.busStopName)
//                // EndView로 이동
//                navigateToEndView = true
//                notificationManager.locationManager.stopLocationUpdates()
//            }, label: {
//                Text("종료")
//                    .foregroundStyle(.white)
//                    .font(.largeTitle)
//                    .padding()
//                    .padding(.horizontal, 20)
//                    .background(Capsule())
//            })
//            
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.gray.opacity(0.8))
//        .cornerRadius(10)
//        .shadow(radius: 10)
//    }
//}
//
//
//
