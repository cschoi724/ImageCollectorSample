//
//  ImageLoadingView.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/18/25.
//

import SwiftUI

struct ImageLoadingView: View {
    let url: String

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
            } else if phase.error != nil {
                Color.gray
            } else {
                ProgressView()
            }
        }
    }
}
