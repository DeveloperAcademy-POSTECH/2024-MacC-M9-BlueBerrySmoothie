//
//  CityModel.swift
//  BlueberrySmoothie
//
//  Created by 문재윤 on 10/31/24.
//
import Foundation

struct City: Codable, Identifiable {
    let id = UUID()
    let citycode: Int
    let cityname: String
}
