//
//  ContentView.swift
//  iOS Comics
//
//  Created by Philipp on 12.05.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var model = ViewModel()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        self.model.previousComic()
                    }) {
                        Image(systemName: "arrowtriangle.left.fill")
                            .padding()
                    }

                    VStack {
                        Text(model.id)
                        Text(model.title)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: {
                        self.model.nextComic()
                    }) {
                        Image(systemName: "arrowtriangle.right.fill")
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))

                ScrollableImage(uiImage: model.image, maxScale: 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarTitle(Text(model.strip), displayMode: .inline)
        }
        .onAppear {
            self.model.refresh()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
