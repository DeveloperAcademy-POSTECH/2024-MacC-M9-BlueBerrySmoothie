//
//  KeyboardDismiss.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/21/24.
//

import SwiftUI

// 키보드를 내리는 함수
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
