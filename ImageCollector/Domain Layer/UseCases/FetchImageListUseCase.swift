//
//  FetchImageListUseCase.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Combine

protocol FetchImageListUseCase {
    func execute() -> AnyPublisher<[ImageInfo], ServiceError>
}

final class FetchImageListUseCaseImpl: FetchImageListUseCase {
    private let repository: ImageRepository

    init(repository: ImageRepository) {
        self.repository = repository
    }
}

extension FetchImageListUseCaseImpl {
    func execute() -> AnyPublisher<[ImageInfo], ServiceError> {
        return repository.fetchImageList()
    }
}
