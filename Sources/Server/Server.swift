//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 10/30/23.
//

import Foundation
import Distributed
import Monotonic
import WebSocketActors
import Logging

@main
struct Server {
    
    static func main() async throws {
        var logger = Logger(label: "Server")
        logger.logLevel = .debug
        
        let address = ServerAddress(scheme: .insecure, host: "0.0.0.0", port: 8888)
        let system = try! await WebSocketActorSystem(mode: .server(at: address), logger: logger)
        _ = system.makeLocalActor(id: .counter) {
            Counter(actorSystem: system)
        }

        try await Task.sleep(for: .seconds(1_000_000))
        print("Done.")
    }
}
