//
//  ImageRepositoryImpl.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Combine

final class ImageRepositoryImpl: ImageRepository {
    
}

extension ImageRepositoryImpl {
    func fetchImageList() -> AnyPublisher<ImageInfo, ServiceError> {
        Empty()
            .eraseToAnyPublisher()
    }
}
