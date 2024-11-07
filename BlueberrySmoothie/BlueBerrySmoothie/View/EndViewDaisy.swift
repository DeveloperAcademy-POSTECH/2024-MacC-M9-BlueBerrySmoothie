//
//  EndView.swift
//  BlueBerrySmoothie
//
//  Created by 원주연 on 11/5/24.
//

import SwiftUI

struct EndViewDaisy: View {
    let alert: Alert

    var body: some View {
        Text("알람종료")
        Text("알람이 종료되었어요.\n하차 후 펼쳐질 일상을 응원해요!")
        Text(alert.busNumber)
        Text(alert.busStopName)
    }
}


