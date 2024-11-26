//
//  OnboardingView.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 11/24/24.
//
import SwiftUI
import UserNotifications

struct OnboardingPage {
    var imageName: String
    var title1: String
    var title2: String
    var description: String
    var buttonText: String
}

struct OnboardingView: View {

    
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showSelectCityView = false
    @State private var selectedCity: City = City(id: "1", category: "없음", name: "선택된 도시 없음", consonant: "ㅋ") // 선택된 도시 저장
    let userDefaultsKey = "CityCodeKey"
    @State private var showImage = false
    
    private func loadCityCode() {
        let savedCityID = UserDefaults.standard.string(forKey: "\(userDefaultsKey)ID") ?? "1"
        let savedCityName = UserDefaults.standard.string(forKey: "\(userDefaultsKey)Name") ?? "선택된 도시 없음"
        selectedCity = City(id: savedCityID, category: "없음", name: savedCityName, consonant: "ㅋ")
    }
    
    var onboardingPages = [
        OnboardingPage(imageName: "OnboardingEndView", title1: "핫챠 사용을 위해", title2: "위치 사용을 허용해 주세요.", description: "권한을 허용하지 않으면 핫챠를 사용할 수 없어요.", buttonText: "허용하기"),
        OnboardingPage(imageName: "OnboardingEndView", title1: "핫챠 사용을 위해", title2: "위치 사용을 허용해 주세요.", description: "권한을 허용하지 않으면 핫챠를 사용할 수 없어요.", buttonText: "다음"),
        OnboardingPage(imageName: "OnboardingStartView", title1: "평소 버스를 이용하는 지역은", title2: "어디신가요?", description: "핫챠는 정류장 위치기반 알람이에요.", buttonText: "지역 선택하기"),
        OnboardingPage(imageName: "OnboardingEndView", title1: "지역이 부산으로 설정되었어요", title2: "", description: "항상 이용하는 버스와 정류장으로 알람을 설정해보세요.", buttonText: "시작하기")
    ]
    
    var body: some View {
        VStack {
            // 현재 페이지에 따라 적절한 내용을 보여줍니다.
            VStack {
                if currentPage == 0 || currentPage == 1 {
                    Text(onboardingPages[0].title1)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 100)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(onboardingPages[0].title2)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(onboardingPages[0].description)
                        .font(.body)
                        .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        
                        
                        InfoCardView(
                            icon: "mark",
                            title: "위치 (앱을 사용하는 동안 허용)",
                            descriptions: [
                                "알람을 활성화 한 후 내가 탄 버스의",
                                "실시간 위치를 확인할 때 사용합니다."
                            ]
                        )
                        
                        InfoCardView(
                            icon:"bell",
                            title: "알림 (허용)",
                            descriptions: [
                                "미리 설정한 정류장에서",
                                "알람을 울릴 때 사용합니다."
                            ]
                        )
                        
                        InfoCardView(
                            icon: "busicon",
                            title: "백그라운드 위치 (항상 허용)",
                            descriptions: [
                                "앱이 백그라운드에서 실행될때도",
                                "알람을 울릴 때 사용합니다."
                            ]
                        )
                        
                    }
                    .padding(.top, 40)
                }
                else if currentPage == 2 {
                    Text(onboardingPages[2].title1)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 100)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(onboardingPages[2].title2)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(onboardingPages[2].description)
                        .font(.body)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
            
                } else if currentPage == 3 {
                    HStack{
                      if selectedCity.name.hasSuffix("군") {
                          Text("지역이 \(selectedCity.name)으로 설정되었어요.")
                      } else if selectedCity.name.hasSuffix("도") || selectedCity.name.hasSuffix("시") || selectedCity.name.hasSuffix("구") {
                          Text("지역이 \(selectedCity.name)로 설정되었어요.")
                      } else {
                          Text("지역이 \(selectedCity.name)로 설정되었어요.")
                      }
                  }
                      .font(.title2)
                      .fontWeight(.bold)
                      .padding(.top, 100)
                      .padding(.bottom, 12)
                      .frame(maxWidth: .infinity, alignment: .leading)
                    Text(onboardingPages[3].description)
                        .font(.body)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                }
                
                Spacer()
                if currentPage >= 2 {
                    Image(onboardingPages[currentPage].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 280)
                        .padding(.bottom, 100)
                        .scaleEffect(showImage ? 1.0 : 0.5)  // "뿅" 효과를 위해 이미지 크기 확대
                        .opacity(showImage ? 1.0 : 0)  // 이미지가 점차 나타나도록
                        .animation(showImage ? .easeOut(duration: 0.5) : .easeIn(duration: 0), value: showImage)
                        .onAppear {
                            // 페이지가 화면에 나타날 때 이미지 애니메이션 시작
                            showImage = true
                        }
                        .onChange(of: currentPage){
                            // 페이지가 화면에 나타날 때 이미지 애니메이션 시작
                            showImage = true
                        }
                }
                if currentPage == 3 {
                    Button(action: {
                        showSelectCityView.toggle()  // Show the city selection view again
                    }) {
                        Text("지역 다시 선택하기")  // Button text
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial) // Change to your preferred color
                            .foregroundColor(.gray3)
                            .cornerRadius(10)
                            
                    }
                }
                
                Spacer()
                
                // 버튼 클릭 시 페이지 변경
                Button(action: {
                    if currentPage == 2 {  // 첫 번째 페이지에서 지역 선택하기 버튼을 누르면
                        showSelectCityView.toggle()  // SelectCityView를 sheet로 표시
                        showImage = false
                        
                    } else {
                        if currentPage == onboardingPages.count - 1 {
                            hasSeenOnboarding = true // 마지막 페이지에서 완료 처리
                            showImage = false
                        } else {
                            currentPage += 1
                            showImage = false
                            LocationManager.shared.checkLocationAuthorization()
                            NotificationManager.instance.requestAuthorization()
                        }
                    }
                }) {
                    Text(onboardingPages[currentPage].buttonText)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.darkgray1)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom,30)
                .sheet(isPresented: $showSelectCityView) {
                    // sheet로 SelectCityView를 띄움
                    SelectCityView(selectedCity: $selectedCity)  // 실제로 띄울 뷰
                        .onDisappear {
                            // SelectCityView가 닫힌 후, 선택된 도시가 있으면 currentPage를 증가시켜서 자동으로 다음 페이지로 전환
                            if selectedCity.name != "선택된 도시 없음" {
                                currentPage = min(currentPage + 1, onboardingPages.count - 1)
                    
                            }
                            showImage = true
                        }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingView()
}
