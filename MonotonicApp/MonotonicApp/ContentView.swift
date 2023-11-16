//
//  ContentView.swift
//  MonotonicApp
//
//  Created by Stuart A. Malone on 10/30/23.
//

import SwiftUI
import Monotonic

@MainActor
struct ContentView: View {
    var model: Model
    
    var body: some View {
        VStack {
            Text(model.count.description)
            
            Button("Click") {
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
//
//#Preview {
//    ContentView()
//}
