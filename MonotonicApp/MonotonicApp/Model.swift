//
//  Model.swift
//  MonotonicApp
//
//  Created by Stuart A. Malone on 10/30/23.
//

import Foundation
import Monotonic
import SwiftUI
import WebSocketActors

@MainActor @Observable
final class Model: LocalModel {
    var count: Int = 0
    var _system: WebSocketActorSystem?
    var _counter: Counter?
    var _monitor: CountMonitor?
    
    var system: WebSocketActorSystem {
        get async {
            if let system = _system {
                return system
            }
            let system = try! await WebSocketActorSystem(mode: .client(of: ServerAddress(scheme: .insecure, host: "ravana.local", port: 8888)))
            _system = system
            return system
        }
    }
    
    var counter: Counter {
        get async {
            if let counter = _counter {
                return counter
            }
            let counter = try! Counter.resolve(id: .counter, using: await system)
            _counter = counter
            return counter
        }
    }
    
    var monitor: CountMonitor {
        get async {
            if let monitor = _monitor {
                return monitor
            }
            let system = await system
            let monitor = system.makeActor {
                CountMonitor(actorSystem: system, model: self)
            }
            _monitor = monitor
            return monitor
        }
    }
    
    func set(count: Int) {
        self.count = count
    }
    
    func click() async throws {
        try await counter.click()
    }
    
    func register() async throws {
        try await counter.register(monitor: monitor)
    }
}
