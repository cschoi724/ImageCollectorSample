//
//  PresentationAssembly.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Swinject
import ComposableArchitecture
import Foundation

public struct PresentationAssembly: Assembly {
    public func assemble(container: Swinject.Container) {
        container.register(MainFeature.self) { resolver in
            return MainFeature(
                environment: .init(
                    fetchImageListUseCase: resolver.resolve(FetchImageListUseCase.self)!,
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            )
        }
    }
}
