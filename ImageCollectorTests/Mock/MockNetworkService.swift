//
//  MockNetworkService.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Combine
import Foundation

@testable import ImageCollector

final class MockNetworkService: NetworkService {
    var mockResponse: Any?
    var mockError: APIError?
    
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError> {
        if let response = mockResponse as? T {
            return Just(response)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        } else if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            return Fail(error: .networkError(NSError(domain: "Mock Error", code: -1, userInfo: nil)))
                .eraseToAnyPublisher()
        }
        
    }
}
