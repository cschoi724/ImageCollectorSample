//
//  DataAssembly.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Foundation
import Swinject

public struct DataAssembly: Assembly {
    public func assemble(container: Swinject.Container) {
        container.register(NetworkConfiguration.self) { _ in
            let url = URL(string: "https://api.thecatapi.com")!
            return APINetworkConfig(
                baseURL: url
            )
        }
        
        container.register(NetworkService.self) { resolver in
            return DefaultNetworkService(
                configuration: resolver.resolve(NetworkConfiguration.self)!
            )
        }

        container.register(ImageRepository.self) { resolver in
            return ImageRepositoryImpl(
                networkService: resolver.resolve(NetworkService.self)!
            )
        }
    }
}
