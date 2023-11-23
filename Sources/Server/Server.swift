//
//  Server.swift
//
//
//  Created by Stuart A. Malone on 10/30/23.
//

import ArgumentParser
import Distributed
import Foundation
import Logging
import Monotonic
import WebSocketActors

@main
struct Server: AsyncParsableCommand {
    @Option(name: .shortAndLong, help: "The host name or IP address to listen on.")
    var host: String = "0.0.0.0"

    @Option(name: .shortAndLong, help: "The port number to listen on.")
    var port: Int = 8888

    mutating func run() async throws {
        var logger = Logger(label: "Server")
        logger.logLevel = .trace

        let address = ServerAddress(scheme: .insecure, host: host, port: port)
        do {
            let system = try await WebSocketActorSystem(mode: .server(at: address), logger: logger)
            
            _ = system.makeLocalActor(id: .counter) {
                Counter(actorSystem: system)
            }
            
            while true {
                try await Task.sleep(for: .seconds(1_000_000))
            }
        }
        catch {
            logger.error("\(error)")
        }
    }
}
