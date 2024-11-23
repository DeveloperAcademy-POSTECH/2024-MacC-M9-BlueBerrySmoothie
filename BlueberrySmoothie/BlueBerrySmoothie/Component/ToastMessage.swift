//
//  ToastMessage.swift
//  BlueBerrySmoothie
//
//  Created by 원주연 on 11/11/24.
//

import Foundation
import SwiftUI

struct ToastMessage: ViewModifier {
    @Binding var isShowing: Bool // easeInOut animation 효과 적용을 위함
    var message: String
    @State private var toastWorkingItem: DispatchWorkItem? = nil // 토스트 메시지가 중첩 호출되었을 때 관리
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.caption) // TODO: body2로 font 바꾸기
                        .padding()
                        .background(.gray2.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.bottom, 40)
                        .onAppear {
                            // 이미 실행 중인 토스트 메시지 작업이 있다면 취소
                            toastWorkingItem?.cancel()
                            
                            // 새로운 토스트 메시지 생성
                            let newToastMessage = DispatchWorkItem {
                                withAnimation {
                                    isShowing = false // 토스트 메시지를 숨김
                                }
                            }
                            
                            // 작업 저장 및 실행
                            toastWorkingItem = newToastMessage
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: newToastMessage) // n초 후 토스트 메시지를 숨김
                        }
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: isShowing)
                .zIndex(0) // toast 메시지가 사라지지 않은 상태로 누를 경우 toast가 일어날 정류장 선택 sheet위로 올라오기 때문에 dimension을 sheet보다 아래로 조정해줌
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastMessage(isShowing: isShowing, message: message))
    }
}
