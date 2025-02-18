//
//  MainView.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    let store: StoreOf<MainFeature>
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                GeometryReader { geometry in
                    VStack {
                        ImageGridView(viewStore: viewStore)
                    }
                    .onViewDidLoad {
                        viewStore.send(.loadData)
                    }
                    .deviceOrientation(viewStore: viewStore)
                }
            }
        }
    }
}

