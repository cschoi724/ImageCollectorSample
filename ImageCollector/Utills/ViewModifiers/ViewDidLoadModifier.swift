//
//  ViewDidLoadModifier.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/18/25.
//

import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !didLoad {
                    action()
                    didLoad = true
                }
            }
    }
}

extension View {
    func onViewDidLoad(perform action: @escaping () -> Void) -> some View {
        self.modifier(ViewDidLoadModifier(action: action))
    }
}
