//
//  ImageCell.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import SwiftUI

struct ImageCell: View {
    let imageInfo: ImageInfo
    
    var body: some View {
        AsyncImage(url: URL(string: imageInfo.url)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else if phase.error != nil {
                Color.gray
            } else {
                ProgressView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
