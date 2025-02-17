//
//  ImageCollectorApp.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import SwiftUI
import Swinject
import ComposableArchitecture

@main
struct ImageCollectorApp: App {
    let injector: DependencyInjector

    init() {
        injector = DependencyInjectorImpl(container: Container())
        injector.assemble([
            DataAssembly(),
            DomainAssembly(),
            PresentationAssembly()
        ])
    }

    var body: some Scene {
        WindowGroup {
            let feature = injector.resolve(MainFeature.self)
            MainView(
                store: StoreOf<MainFeature>(
                    initialState: MainFeature.State(),
                    reducer: {
                        feature
                    }
                )
            )
        }
    }
}
