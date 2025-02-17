//
//  APIError.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

enum APIError: Error {
    case invalidURL
    case invalidBody
    case badServerResponse(statusCode: Int)
    case decodingError(String)
    case networkError(Error)
}
