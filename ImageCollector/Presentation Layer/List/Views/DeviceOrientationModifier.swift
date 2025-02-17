//
//  DeviceOrientationModifier.swift.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture

struct DeviceOrientationModifier: ViewModifier {
    let viewStore: ViewStore<MainFeature.State, MainFeature.Action>
    
    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIDevice.orientationDidChangeNotification
                ),
                perform: { _ in
                    let orientation = UIDevice.current.orientation
                    let isPortrait = orientation == .portrait
                    viewStore.send(.deviceOrientationChanged(isPortrait))
                }
            )
    }
}


extension View {
    func deviceOrientation(viewStore: ViewStore<MainFeature.State, MainFeature.Action>) -> some View {
        self.modifier(
            DeviceOrientationModifier(
                viewStore: viewStore
            )
        )
    }
}
