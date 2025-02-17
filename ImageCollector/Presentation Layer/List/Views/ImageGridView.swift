//
//  ImageGridView.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture

struct ImageGridView: View {
    let viewStore: ViewStore<MainFeature.State, MainFeature.Action>
    
    var body: some View {
        GeometryReader { geometry in
            let width = viewStore.isPortrait ? geometry.size.width : 300
            let height = viewStore.isPortrait ? geometry.size.width : 120
            ScrollView(.horizontal) {
                ScrollView {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 10),
                            count: viewStore.isPortrait ? 1 : 5
                        ),
                        spacing: 10,
                        content: {
                            ForEach(viewStore.results, id: \.id) { imageInfo in
                                ImageCell(imageInfo: imageInfo)
                                .frame(width: width, height: height)
                                .onAppear {
                                    if imageInfo == viewStore.results.last {
                                        viewStore.send(.loadNextPage)
                                    }
                                }
                                .onTapGesture {
                                    print(imageInfo)
                                }
                            }
                        }
                    )
                    
                    .padding(.horizontal, 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}
