//
//  City.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/21/24.
//
import SwiftUI
// 도시 모델
class City: Identifiable {
    var id: String
    var category: String  // 카테고리 (지역)
    var name: String      // 도시 이름
    let consonant: String
    
    init(id: String, category: String, name: String, consonant: String) {
        self.id = id
        self.category = category
        self.name = name
        self.consonant = consonant
    }
}

// 데이터 초기화City
let cities: [City] = [
    // 광역시/특별시/특별자치도
    City(id: "12", category: "광역시/특별시/특별자치도", name: "세종특별자치시", consonant: "ㅅ"),
    City(id: "21", category: "광역시/특별시/특별자치도", name: "부산광역시", consonant: "ㅂ"),
    City(id: "22", category: "광역시/특별시/특별자치도", name: "대구광역시", consonant: "ㄷ"),
    City(id: "23", category: "광역시/특별시/특별자치도", name: "인천광역시", consonant: "ㅇ"),
    City(id: "24", category: "광역시/특별시/특별자치도", name: "광주광역시", consonant: "ㄱ"),
    City(id: "25", category: "광역시/특별시/특별자치도", name: "대전광역시/계룡시", consonant: "ㄷ"),
    City(id: "26", category: "광역시/특별시/특별자치도", name: "울산광역시", consonant: "ㅇ"),
    City(id: "39", category: "광역시/특별시/특별자치도", name: "제주특별자치도", consonant: "ㅈ"),

    // 경기도
    City(id: "31010", category: "경기도", name: "수원시", consonant: "ㅅ"),
    City(id: "31020", category: "경기도", name: "성남시", consonant: "ㅅ"),
    City(id: "31030", category: "경기도", name: "의정부시", consonant: "ㅇ"),
    City(id: "31040", category: "경기도", name: "안양시", consonant: "ㅇ"),
    City(id: "31050", category: "경기도", name: "부천시", consonant: "ㅂ"),
    City(id: "31060", category: "경기도", name: "광명시", consonant: "ㄱ"),
    City(id: "31070", category: "경기도", name: "평택시", consonant: "ㅍ"),
    City(id: "31080", category: "경기도", name: "동두천시", consonant: "ㄷ"),
    City(id: "31090", category: "경기도", name: "안산시", consonant: "ㅇ"),
    City(id: "31100", category: "경기도", name: "고양시", consonant: "ㄱ"),
    City(id: "31110", category: "경기도", name: "과천시", consonant: "ㄱ"),
    City(id: "31120", category: "경기도", name: "구리시", consonant: "ㄱ"),
    City(id: "31130", category: "경기도", name: "남양주시", consonant: "ㄴ"),
    City(id: "31140", category: "경기도", name: "오산시", consonant: "ㅇ"),
    City(id: "31150", category: "경기도", name: "시흥시", consonant: "ㅅ"),
    City(id: "31160", category: "경기도", name: "군포시", consonant: "ㄱ"),
    City(id: "31170", category: "경기도", name: "의왕시", consonant: "ㅇ"),
    City(id: "31180", category: "경기도", name: "하남시", consonant: "ㅎ"),
    City(id: "31190", category: "경기도", name: "용인시", consonant: "ㅇ"),
    City(id: "31200", category: "경기도", name: "파주시", consonant: "ㅍ"),
    City(id: "31210", category: "경기도", name: "이천시", consonant: "ㅇ"),
    City(id: "31220", category: "경기도", name: "안성시", consonant: "ㅇ"),
    City(id: "31230", category: "경기도", name: "김포시", consonant: "ㄱ"),
    City(id: "31240", category: "경기도", name: "화성시", consonant: "ㅎ"),
    City(id: "31250", category: "경기도", name: "광주시", consonant: "ㄱ"),
    City(id: "31260", category: "경기도", name: "양주시", consonant: "ㅇ"),
    City(id: "31270", category: "경기도", name: "포천시", consonant: "ㅍ"),
    City(id: "31320", category: "경기도", name: "여주시", consonant: "ㅇ"),
    City(id: "31350", category: "경기도", name: "연천군", consonant: "ㅇ"),
    City(id: "31370", category: "경기도", name: "가평군", consonant: "ㄱ"),
    City(id: "31380", category: "경기도", name: "양평군", consonant: "ㅇ"),

    // 강원도
    City(id: "32010", category: "강원도", name: "춘천시", consonant: "ㅊ"),
    City(id: "32020", category: "강원도", name: "원주시/횡성군", consonant: "ㅇ"),
    City(id: "32050", category: "강원도", name: "태백시", consonant: "ㅌ"),
    City(id: "32310", category: "강원도", name: "홍천군", consonant: "ㅎ"),
    City(id: "32360", category: "강원도", name: "철원군", consonant: "ㅊ"),
    City(id: "32410", category: "강원도", name: "양양군", consonant: "ㅇ"),

    // 충청북도
    City(id: "33010", category: "충청북도", name: "청주시", consonant: "ㅊ"),
    City(id: "33020", category: "충청북도", name: "충주시", consonant: "ㅊ"),
    City(id: "33030", category: "충청북도", name: "제천시", consonant: "ㅈ"),
    City(id: "33320", category: "충청북도", name: "보은군", consonant: "ㅂ"),
    City(id: "33330", category: "충청북도", name: "옥천군", consonant: "ㅇ"),
    City(id: "33340", category: "충청북도", name: "영동군", consonant: "ㅇ"),
    City(id: "33350", category: "충청북도", name: "진천군", consonant: "ㅈ"),
    City(id: "33360", category: "충청북도", name: "괴산군", consonant: "ㄱ"),
    City(id: "33370", category: "충청북도", name: "음성군", consonant: "ㅇ"),
    City(id: "33380", category: "충청북도", name: "단양군", consonant: "ㄷ"),

    // 충청남도
    City(id: "34010", category: "충청남도", name: "천안시", consonant: "ㅊ"),
    City(id: "34020", category: "충청남도", name: "공주시", consonant: "ㄱ"),
    City(id: "34040", category: "충청남도", name: "아산시", consonant: "ㅇ"),
    City(id: "34050", category: "충청남도", name: "서산시", consonant: "ㅅ"),
    City(id: "34060", category: "충청남도", name: "논산시", consonant: "ㄴ"),
    City(id: "34070", category: "충청남도", name: "계룡시", consonant: "ㄱ"),
    City(id: "34330", category: "충청남도", name: "부여군", consonant: "ㅂ"),
    City(id: "34390", category: "충청남도", name: "당진시", consonant: "ㄷ"),

    // 전라북도
    City(id: "35010", category: "전라북도", name: "전주시", consonant: "ㅈ"),
    City(id: "35020", category: "전라북도", name: "군산시", consonant: "ㄱ"),
    City(id: "35040", category: "전라북도", name: "정읍시", consonant: "ㅈ"),
    City(id: "35050", category: "전라북도", name: "남원시", consonant: "ㄴ"),
    City(id: "35060", category: "전라북도", name: "김제시", consonant: "ㄱ"),
    City(id: "35320", category: "전라북도", name: "진안군", consonant: "ㅈ"),
    City(id: "35330", category: "전라북도", name: "무주군", consonant: "ㅁ"),
    City(id: "35340", category: "전라북도", name: "장수군", consonant: "ㅈ"),
    City(id: "35350", category: "전라북도", name: "임실군", consonant: "ㅇ"),
    City(id: "35360", category: "전라북도", name: "순창군", consonant: "ㅅ"),
    City(id: "35370", category: "전라북도", name: "고창군", consonant: "ㄱ"),
    City(id: "35380", category: "전라북도", name: "부안군", consonant: "ㅂ"),

    // 전라남도
    City(id: "36010", category: "전라남도", name: "목포시", consonant: "ㅁ"),
    City(id: "36020", category: "전라남도", name: "여수시", consonant: "ㅇ"),
    City(id: "36030", category: "전라남도", name: "순천시", consonant: "ㅅ"),
    City(id: "36040", category: "전라남도", name: "나주시", consonant: "ㄴ"),
    City(id: "36060", category: "전라남도", name: "광양시", consonant: "ㄱ"),
    City(id: "36320", category: "전라남도", name: "곡성군", consonant: "ㄱ"),
    City(id: "36330", category: "전라남도", name: "구례군", consonant: "ㄱ"),
    City(id: "36350", category: "전라남도", name: "해남군", consonant: "ㅎ"),
    City(id: "36360", category: "전라남도", name: "영광군", consonant: "ㅇ"),
    City(id: "36370", category: "전라남도", name: "장성군", consonant: "ㅈ"),
    City(id: "36380", category: "전라남도", name: "완도군", consonant: "ㅇ"),
    City(id: "36390", category: "전라남도", name: "진도군", consonant: "ㅈ"),
    City(id: "36400", category: "전라남도", name: "봉화군", consonant: "ㅂ"),
    City(id: "36410", category: "전라남도", name: "경주시", consonant: "ㄱ"),

    // 경상북도
    City(id: "37010", category: "경상북도", name: "포항시", consonant: "ㅍ"),
    City(id: "37020", category: "경상북도", name: "경주시", consonant: "ㄱ"),
    City(id: "37030", category: "경상북도", name: "김천시", consonant: "ㄱ"),
    City(id: "37040", category: "경상북도", name: "안동시", consonant: "ㅇ"),
    City(id: "37050", category: "경상북도", name: "구미시", consonant: "ㄱ"),
    City(id: "37310", category: "경상북도", name: "영천시", consonant: "ㅇ"),
    City(id: "37320", category: "경상북도", name: "상주시", consonant: "ㅅ"),
    City(id: "37330", category: "경상북도", name: "문경시", consonant: "ㅁ"),
    City(id: "37340", category: "경상북도", name: "예천군", consonant: "ㅇ"),
    City(id: "37350", category: "경상북도", name: "봉화군", consonant: "ㅂ"),
    City(id: "37360", category: "경상북도", name: "울진군", consonant: "ㅇ"),

    // 경상남도
    City(id: "38010", category: "경상남도", name: "창원시", consonant: "ㅊ"),
    City(id: "38020", category: "경상남도", name: "진주시", consonant: "ㅈ"),
    City(id: "38030", category: "경상남도", name: "통영시", consonant: "ㅌ"),
    City(id: "38040", category: "경상남도", name: "사천시", consonant: "ㅅ"),
    City(id: "38050", category: "경상남도", name: "김해시", consonant: "ㄱ"),
    City(id: "38060", category: "경상남도", name: "밀양시", consonant: "ㅁ"),
    City(id: "38310", category: "경상남도", name: "거제시", consonant: "ㄱ"),
    City(id: "38320", category: "경상남도", name: "함안군", consonant: "ㅎ"),
    City(id: "38330", category: "경상남도", name: "창녕군", consonant: "ㅊ"),
    City(id: "38340", category: "경상남도", name: "고성군", consonant: "ㄱ"),
    City(id: "38350", category: "경상남도", name: "하동군", consonant: "ㅎ")
]
