//
//  Model.swift
//  MonotonicApp
//
//  Created by Stuart A. Malone on 10/30/23.
//

import Foundation
import Monotonic
import SwiftUI

@MainActor @Observable
final class Model: LocalModel {
    var count: Int = 0
    var clicker: Clicker? = nil
    var counter: Counter
    
    init(counter: Counter) {
        self.counter = counter
    }
    
    func set(count: Int) async {
        self.count = count
    }
    
    func ensureClickerExists() async {
        if clicker == nil {
            let system = WebSocketActorSystem.shared
            clicker = system.makeActorWithID(.init(protocol: "ws", host: system.host, port: system.port, id: UUID().uuidString)) {
                Clicker(actorSystem: WebSocketActorSystem.shared,
                                            counter: counter,
                                            model: self)
            }
        }
    }
    
    func click() async throws {
        await ensureClickerExists()
        try await clicker?.click()
    }
    
    func register() async throws {
        await ensureClickerExists()
        try await counter.register(clicker: clicker!)
    }
}
