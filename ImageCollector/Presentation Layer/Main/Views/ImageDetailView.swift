//
//  ImageDetailView.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/18/25.
//

import SwiftUI

struct ImageDetailView: View {
    let imageInfo: ImageInfo
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    ImageLoadingView(url: imageInfo.url)
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = min(max(value, 1.0), 3.0)
                                }
                        )
                        .frame(width: geometry.size.width)
                        .scaledToFit()
                }
            }
            .navigationBarTitle("\(imageInfo.id)", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            )
            .navigationBarBackButtonHidden(true)
        }
    }
}
