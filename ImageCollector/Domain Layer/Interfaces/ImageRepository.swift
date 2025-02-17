//
//  ImageRepository.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Combine

protocol ImageRepository {
    func fetchImageList() -> AnyPublisher<[ImageInfo], ServiceError>
}
