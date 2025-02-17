//
//  MockImageRepository.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Combine
@testable import ImageCollector

final class MockImageRepository: ImageRepository {
    var mockResponse: [ImageInfo] = []
    var mockError: ServiceError?

    func fetchImageList() -> AnyPublisher<[ImageInfo], ServiceError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(mockResponse)
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }
}
