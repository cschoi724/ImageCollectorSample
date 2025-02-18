//
//  ImageLoadingView.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/18/25.
//

import SwiftUI

struct ImageLoadingView: View {
    let imageInfo: ImageInfo

    var body: some View {
        AsyncImage(url: URL(string: imageInfo.url)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else if let imageData = imageInfo.imageData,
                      let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if phase.error != nil {
                Color.gray
            } else {
                ProgressView()
            }
        }
    }
}
