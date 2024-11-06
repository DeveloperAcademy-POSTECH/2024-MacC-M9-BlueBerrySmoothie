//
//  NetworkHelper.swift
//  BlueBerrySmoothie
//
//  Created by Yeji Seo on 10/31/24.
//

import Foundation

enum APIError: Error {
    case invalidAPI
    case invalidURL
    case requestFailed(statusCode: Int)
    case dataLoadingError(underlyingError: Error)
    case decodingError(underlyingError: Error)
}
