//
//  DummyView.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/30/24.
//
import SwiftUI


struct SelectCityView: View {
    @State private var cities: [City] = []
    
    var body: some View {
        NavigationStack {
            List(cities) { city in
                NavigationLink(destination: SelectBusView()) {
                    Text(city.cityname)
                        .font(.headline)
                        .padding()
                    Text("\(city.citycode)")
                }
            }
            .navigationTitle("도시 목록")
            .onAppear {
                fetchCityData { fetchedCities in
                    self.cities = fetchedCities
                }
            }
        }
    }
}



