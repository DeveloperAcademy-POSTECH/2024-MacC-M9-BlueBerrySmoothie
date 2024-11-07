//
//  AlarmEndView.swift
//  BlueBerrySmoothie
//
//  Created by 이진경 on 11/5/24.
//

import SwiftUI

struct AlarmEndView: View {
    var body: some View {
        VStack(spacing: 20) {
            
            Text("출근하기")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top, 70)
            
            Text("알람 종료")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 20)
            
            VStack(spacing: 2) {
                Text("알람이 무사히 종료되었어요.")
                Text("하차 후 펼쳐질 하루를 응원해요!")
            }
            .font(.body)
            .foregroundColor(Color.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .padding(.top, 10)
            
            Image("알람종료")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .padding(.top, 20)
            
            
            Text("행복 복지센터")
                .font(.title2)
                .fontWeight(.light)
                .foregroundColor(.black)
            
            
            Text("2 정거장 전")
                .font(.subheadline)
                .foregroundColor(Color.orange)
                .padding(.top, 2)
            
            Spacer()
            
            // 알람 정보 큰 네모 상자
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    VStack(spacing: 15) {
                        Text("알람 시작 아시아드경기장(공촌사거리)")
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                        
                        Text("총 수면 시간 2시간 30분")
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            
            // 하차 알림 끄기 버튼
            Button(action: {
                print("하차 알림 끄기 버튼이 눌렸습니다.")
            }) {
                Text("하차 알림 끄기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding(.bottom, 30) 
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct AlarmEndView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmEndView()
    }
}
