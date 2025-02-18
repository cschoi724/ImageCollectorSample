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
            let size = viewStore.isPortrait
                ? CGSize(width: geometry.size.width, height: geometry.size.width)
                : CGSize(width: 300, height: 120)
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.fixed(size.width), spacing: 10),
                            count: viewStore.isPortrait ? 1 : 5
                        ),
                        spacing: 10,
                        content: { buildGrid(with: size) }
                    )
                    .padding(.horizontal, 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    private func buildGrid(with size: CGSize) -> some View {
        ForEach(viewStore.results, id: \.id) { imageInfo in
            NavigationLink(
                destination: ImageDetailView(imageInfo: imageInfo),
                label: {
                    ImageCell(imageInfo: imageInfo, size: size)
                        .frame(width: size.width, height: size.height)
                        .onAppear {
                            if imageInfo == viewStore.results.last {
                                viewStore.send(.loadNextPage)
                            }
                        }
                }
            )
        }
    }
}
