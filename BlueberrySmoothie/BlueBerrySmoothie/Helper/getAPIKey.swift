//
//  getAPIKey.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 11/1/24.
//

import Foundation

func getAPIKey() -> String? {
    return Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
}
