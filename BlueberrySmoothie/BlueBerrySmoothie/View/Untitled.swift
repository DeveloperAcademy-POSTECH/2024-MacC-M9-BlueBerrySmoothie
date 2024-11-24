//
//  Untitled.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/23/24.
//
import SwiftUI

// 항목 모델: 초성 (Consonant)과 단어 (Word)를 갖는 구조체
struct Item: Identifiable {
    var id = UUID()
    var consonant: String
    var word: String
}

struct ContentView: View {
    // 한글 자음 인덱스
    let index = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    // 항목 리스트
    let items: [Item] = [
        Item(consonant: "ㄱ", word: "가방"),
        Item(consonant: "ㄱ", word: "가구"),
        Item(consonant: "ㄱ", word: "가전"),
        Item(consonant: "ㄴ", word: "나무"),
        Item(consonant: "ㄴ", word: "나비"),
        Item(consonant: "ㄷ", word: "다리"),
        Item(consonant: "ㄷ", word: "다람쥐"),
        Item(consonant: "ㄹ", word: "라디오"),
        Item(consonant: "ㄹ", word: "라면"),
        Item(consonant: "ㅁ", word: "마술"),
        Item(consonant: "ㅁ", word: "마음"),
        Item(consonant: "ㅂ", word: "바다"),
        Item(consonant: "ㅂ", word: "바나나"),
        Item(consonant: "ㅅ", word: "사랑"),
        Item(consonant: "ㅅ", word: "사자"),
        Item(consonant: "ㅇ", word: "아침"),
        Item(consonant: "ㅇ", word: "아이"),
        Item(consonant: "ㅈ", word: "자전거"),
        Item(consonant: "ㅈ", word: "자기"),
        Item(consonant: "ㅊ", word: "차가"),
        Item(consonant: "ㅊ", word: "차별"),
        Item(consonant: "ㅋ", word: "카메라"),
        Item(consonant: "ㅋ", word: "탑"),
        Item(consonant: "ㅍ", word: "파도"),
        Item(consonant: "ㅎ", word: "하늘")
    ]
    
    @State private var scrollToIndex: String? // 현재 선택된 초성
    @State private var scrollViewProxy: ScrollViewProxy? // ScrollViewProxy
    
    var body: some View {
        HStack(spacing: 10) {
            // 항목 리스트
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        ForEach(items) { item in
                            Text(item.word)
                                .id(item.id) // 각 항목에 고유 ID 부여
                                .padding(5)
                                .background(scrollToIndex == item.consonant ? Color.blue.opacity(0.3) : Color.clear)
                                .cornerRadius(5)
                        }
                    }
                    .onAppear {
                        scrollViewProxy = proxy // ScrollViewProxy 초기화
                    }
                }
                .frame(maxWidth: .infinity) // ScrollView 크기 조정
            }
            
            // 초성 스크롤바 (드래그 가능)
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach(index, id: \.self) { letter in
                        Text(letter)
                            .font(.title2)
                            .frame(width: 20, height: 30) // 텍스트 크기 설정
                            
                    }
                }
                .frame(width: 20, height: 420) // 높이를 고정 500으로 설정
                .overlay( // 네모 테두리 추가
                    RoundedRectangle(cornerRadius: 30) // 모서리가 약간 둥근 사각형
                        .stroke(Color.black, lineWidth: 2) // 테두리 색상과 두께
                )
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.orange)
                )
                
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // 터치 위치로 초성 계산
                            let location = value.location.y
                            let letterHeight = 30
                            let position = max(0, min(Int(location / 30), index.count - 1))
                            let selectedLetter = index[position]
                            
                            if scrollToIndex != selectedLetter {
                                scrollToIndex = selectedLetter
                                withAnimation {
                                    if let firstMatch = items.first(where: { $0.consonant == selectedLetter }) {
                                        scrollViewProxy?.scrollTo(firstMatch.id, anchor: .top)
                                    }
                                }
                            }
                        }
                )
            }
            .frame(width: 20) // 인덱스 스크롤바의 너비
        }
        .padding()
    }
}



#Preview {
    ContentView()
}
