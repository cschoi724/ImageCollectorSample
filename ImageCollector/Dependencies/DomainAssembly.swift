//
//  DomainAssembly.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Swinject

public struct DomainAssembly: Assembly {
    public func assemble(container: Swinject.Container) {
        container.register(FetchImageListUseCase.self) { resolver in
            return FetchImageListUseCaseImpl(
                repository: resolver.resolve(ImageRepository.self)!
            )
        }
    }
}
