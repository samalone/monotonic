//
//  ContentView.swift
//  MonotonicApp
//
//  Created by Stuart A. Malone on 10/30/23.
//

import Monotonic
import SwiftUI

@MainActor
struct ContentView: View {
    var model: Model

    var body: some View {
        VStack(spacing: 20) {
            Text(model.statusMessage)

            Text(model.errorMessage)
                .foregroundColor(.red)

            Text(model.count.description)

            Button("Increment") {
                Task {
                    try? await model.click()
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                try? await model.register()
            }
        }
    }
}

#Preview {
    ContentView(model: Model())
}
