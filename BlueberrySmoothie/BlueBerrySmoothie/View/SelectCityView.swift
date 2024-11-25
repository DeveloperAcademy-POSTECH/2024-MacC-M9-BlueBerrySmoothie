//
//  모두화이팅해라.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/21/24.
//


import SwiftUI

struct SelectCityView: View {
    @Binding var selectedCity: City
    @State private var selectedCategory: String = "전체"
    @State private var searchText: String = ""
    @FocusState private var isFocused: Bool // 활성화 상태 추적
    @Environment(\.dismiss) private var dismiss
    
    let userDefaultsKey = "CityCodeKey"
    @State private var savedCityName: String = ""
    
    
    @State private var scrollToIndex: String? // 현재 선택된 초성
    @State private var scrollViewProxy: ScrollViewProxy? // ScrollViewProxy
    @State private var showOverlay: Bool = false // 초성 오버레이 표시 여부
    
    let index = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    var body: some View {
        NavigationView {
            
            ZStack {
                VStack {
//                        // 검색창
//                        TextField("도시 이름 검색", text: $searchText)
//                            .padding(12)
//                            .background(
//                                RoundedRectangle(cornerRadius: 20)
//                                    .fill(isFocused ? Color.white : Color.gray6) // 배경색
//                            )
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(isFocused ? Color.brand : Color.gray5, lineWidth: 1) // 테두리
//                            )
//                            .cornerRadius(20) // cornerRadius를 background와 동일하게 설정
//                            .padding(.horizontal, 20) // 여백 설정
//                            .frame(height: 52) // 높이 설정
//                            .focused($isFocused) // 포커스 상태 업데이트
//                            .tint(.brand)
                    
                    HStack(alignment: .center) {
                        TextField("도시 이름 검색", text: $searchText)
                            .font(.body1)
                            .foregroundStyle(.blackasset)
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 0))
                            .tint(.brand)
                           
                        Spacer()
                        Image("magnifyingglass")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray3)
                            .padding(.trailing, 20.67)
                        
                    }
                    .background(.gray6)
                    .cornerRadius(20)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isFocused == true ? .brand : .gray5, lineWidth: 1)
                    }
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    
                    
                     
                    // 세그먼트 피커
                    CustomCategoryPicker(selectedCategory: $selectedCategory, categories: categories)
                        .padding(.vertical, 20)
                    
                    ScrollViewReader { proxy in
                        // 도시 스크롤 뷰
                        ScrollView(showsIndicators: false) {
                            ForEach(filteredCities.sorted(by: {$0.name < $1.name})) { city in
                                Button(action: {
                                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                        HapticManager.shared.triggerImpactFeedback(style: .medium)
                                    }
                                    
                                    selectedCity = city // 선택된 도시 저장
                                    dismiss()
                                    saveCityCode()
                                    dismissKeyboard()
                                }) {
                                    VStack{
                                        HStack{
                                            Text(city.name)
                                                .padding(.horizontal,20)
                                                .padding(.vertical,15)
                                                .foregroundStyle(.blackasset)
                                                
                                            Spacer()
                                        }

                                        Divider()
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                        } .padding(.horizontal, 20)
                            .onAppear {
                                scrollViewProxy = proxy // ScrollViewProxy 초기화
                            }
                    }
                    
                }
                
                HStack {
                    Spacer()
                // 초성 스크롤바 (드래그 가능)
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        ForEach(index, id: \.self) { letter in
                            Text(letter)
                                .font(.title2)
                                .foregroundStyle(.gray3)
                                .frame(width: 15, height: 23) // 텍스트 크기 설정
                        }
                    }
                    .frame(width: 18, height: 322) // 높이를 고정 500으로 설정
//                    .overlay( // 네모 테두리 추가
//                        RoundedRectangle(cornerRadius: 30) // 모서리가 약간 둥근 사각형
//                            .stroke(Color.black, lineWidth: 2) // 테두리 색상과 두께
//                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray3.opacity(0.2))
                    )
                    
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // 터치 위치로 초성 계산
                                let location = value.location.y
                                let letterHeight = 23
                                let position = max(0, min(Int(location / 23), index.count - 1))
                                let selectedLetter = index[position]
                                
                                if scrollToIndex != selectedLetter {
                                    scrollToIndex = selectedLetter
                                    showOverlay = true // 오버레이 표시
                                    HapticManager.shared.triggerImpactFeedback(style: .medium)
                                    
                                    withAnimation {
                                        if let firstMatch = filteredCities.first(where: { $0.consonant == selectedLetter }) {
                                            scrollViewProxy?.scrollTo(firstMatch.id, anchor: .top)
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation {
                                            showOverlay = false
                                        }
                                    }
                                }
                            }
                    )
                }
                .frame(width: 18) // 인덱스 스크롤바의 너비
            }
                .padding(.top, 170)
                .padding(.horizontal, 10)
                
                
                
                // 초성 오버레이
                    if showOverlay, let scrollToIndex = scrollToIndex {
                        VStack {
                            Spacer()
                            Text(scrollToIndex)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.gray4)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                    
                                )
                                .padding(.bottom, 200) // 화면 중간에 위치하도록 설정
                            Spacer()
                        }
                        .transition(.opacity) // 오버레이 애니메이션
                    }
                
                
                
            }
            .navigationTitle("지역 설정")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                dismissKeyboard()
            }
        }

    }
    
    
    
    
    
    
    
    
    
    
    // 카테고리 목록
    private var categories: [String] {
        var allCategories = cities.map { $0.category }
        allCategories.insert("전체", at: 0) // "전체" 카테고리를 맨 앞에 추가
        let uniqueCategories = Array(Set(allCategories)) // 중복 제거
        return ["전체"] + uniqueCategories.filter { $0 != "전체" }.sorted() // "전체"를 맨 앞에 두고 나머지 카테고리는 정렬
    }
    
    
    
    // 필터링된 도시 리스트
    private var filteredCities: [City] {
        cities.filter { city in
            (selectedCategory == "전체" || city.category == selectedCategory) &&
            (searchText.isEmpty || city.name.contains(searchText))
        }
    }
    
    // 도시 정보 저장
    private func saveCityCode() {
            UserDefaults.standard.set(selectedCity.id, forKey: "\(userDefaultsKey)ID")
            UserDefaults.standard.set(selectedCity.name, forKey: "\(userDefaultsKey)Name")
        }
    
    
}






struct CustomCategoryPicker: View {
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {   
                ForEach(categories, id: \.self) { category in
                    Text(category)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12.5)
                        .background(selectedCategory == category ? Color.gray1 : .clear)
                        .foregroundColor(selectedCategory == category ? .whiteasset : .blackasset)
                        .cornerRadius(20)
                        .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.gray2, lineWidth: 0.5)
                        )
                        .padding(0.5)
                        .onTapGesture {
                            selectedCategory = category
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    CitySettingView()
}
