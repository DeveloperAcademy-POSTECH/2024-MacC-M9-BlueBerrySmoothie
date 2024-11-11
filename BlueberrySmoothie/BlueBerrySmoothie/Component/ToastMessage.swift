//
//  ToastMessage.swift
//  BlueBerrySmoothie
//
//  Created by 원주연 on 11/11/24.
//

import Foundation
import SwiftUI

struct ToastMessage: ViewModifier {
    @Binding var isShowing: Bool
    var message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.caption)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.bottom, 40)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        }
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: isShowing)
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastMessage(isShowing: isShowing, message: message))
    }
}
