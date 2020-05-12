//
//  ScrollableImage.swift
//  iOS Comics
//
//  Created by Philipp on 12.05.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct ScrollableImage: View {

    let uiImage: UIImage
    let image: Image

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var maxScale: CGFloat = 3.0

    init(uiImage: UIImage, scale: CGFloat = 1.0, maxScale: CGFloat = 3.0) {
        self.uiImage = uiImage
        self.image = Image(uiImage: uiImage)

        self.scale = scale
        self.lastScale = scale
        self.maxScale = maxScale
    }

    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                self.scale = self.lastScale * state
                self.scale = max(min(self.scale, self.maxScale), 1/self.maxScale)
                print("scale = \(self.scale)")
            }
            .onEnded({ (finalState) in
                self.scale = max(min(self.lastScale * finalState, self.maxScale), 1/self.maxScale)
                self.lastScale = self.scale
            })
    }

    var body: some View {
        GeometryReader { proxy -> AnyView in

            let scale = self.scale
            let imageWidth = self.uiImage.size.width * scale
            let imageHeight = self.uiImage.size.height * scale

            // Inspired by https://github.com/AndrewOfC/SwiftUIImageView
            let insets = proxy.safeAreaInsets
            let scrollViewWidth = proxy.size.width + insets.leading + insets.trailing
            let scrollViewHeight = proxy.size.height + insets.top + insets.bottom

            let dx: CGFloat = (imageWidth > scrollViewWidth ? (imageWidth - scrollViewWidth) / 2 : 0.0)
            let dy: CGFloat = (imageHeight > scrollViewHeight ? (imageHeight - scrollViewHeight) / 2 : 0.0)

            return AnyView(
                ScrollView([.horizontal, .vertical]) {
                    self.image
                        .resizable()
                        .frame(width: imageWidth, height: imageHeight)
                        .offset(x: dx, y: dy)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .highPriorityGesture(self.magnification)
            )
        }
    }
}



struct ScrollableImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollableImage(uiImage: UIImage(named: "Example")!)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            ScrollableImage(uiImage: UIImage(named: "Start")!)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
