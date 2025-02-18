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
                    .frame(width: size.width, height: size.height)
                    .clipped()
            } else if phase.error != nil {
                Color.gray
                    .frame(width: size.width, height: size.height)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: size.width, height: size.height)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue.opacity(0.8), lineWidth: 3)
                .shadow(radius: 5)
        )
    }
}
