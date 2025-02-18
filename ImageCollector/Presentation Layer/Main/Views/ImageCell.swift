//
//  ImageCell.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import SwiftUI

struct ImageCell: View {
    let imageInfo: ImageInfo
    let size: CGSize
    
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
        .frame(width: size.width, height: size.height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue.opacity(0.8), lineWidth: 3)
                .shadow(radius: 5)
        )
    }
}
