//
//  MainFeature.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Foundation
import ComposableArchitecture
import Combine
import SwiftUI

struct MainFeature: Reducer {
    struct State: Equatable {
        var results: [ImageInfo] = []
        var isLoading: Bool = false
        var isPortrait: Bool = UIDevice.current.orientation == .portrait
    }
    
    enum Action: Equatable {
        case loadData
        case loadNextPage
        case perform
        case responseSuccess([ImageInfo])
        case responseFailure(ServiceError)
        case deviceOrientationChanged(Bool)
    }
    
    struct Environment {
        let fetchImageListUseCase: FetchImageListUseCase
        let mainQueue: AnySchedulerOf<DispatchQueue>
    }
    
    enum ID: Hashable {
        case debounce, throttle
    }
    
    let environment: Environment
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadData:
            state.results = []
            return .run { send in
                await send(.perform)
            }
            .debounce(
                id: ID.debounce,
                for: 0.5,
                scheduler: environment.mainQueue
            )
        case .loadNextPage:
            guard state.isLoading == false else {
                return .none
            }
            state.isLoading = true
            return .run { send in
                await send(.perform)
            }
            .throttle(
                id: ID.throttle,
                for: 1.0,
                scheduler: environment.mainQueue,
                latest: false
            )
        case .perform:
            let imageRequest = environment.fetchImageListUseCase.execute()

            return Effect.publisher {
                imageRequest
                    .map { Action.responseSuccess($0) }
                    .catch { Just(Action.responseFailure($0)) }
                    .eraseToAnyPublisher()
            }
        case .responseSuccess(let newResults):
            state.results += newResults
            state.isLoading = false
            return .none
        case .responseFailure(let error):
            state.results = []
            state.isLoading = false
            print(error)
            return .none
        case .deviceOrientationChanged(let isPortrait):
            state.isPortrait = isPortrait
            return .none
        }
    }
}
