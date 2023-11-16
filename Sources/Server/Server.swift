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

//print("Foo")
//
//let system = await ClusterSystem("FirstSystem") { settings in
//    settings.endpoint.host = "127.0.0.1"
//    settings.endpoint.port = 7337
//}
//
//try await system.terminated

/// Run the server application by selecting the `TicTacFishServer` scheme when opening the Step 2 Workspace in Xcode.
/// You can also run this application directly from the command line, by invoking: `swift run` on macOS 13.
@main
struct Server {
    
    static func main() async throws {
        let address = ServerAddress(scheme: .insecure, host: "localhost", port: 8888)
        let system = try! await WebSocketActorSystem(mode: .server(at: address))
        
        system.registerOnDemandResolveHandler { id in
            // We create new BotPlayers "ad-hoc" as they are requested for.
            // Subsequent resolves are able to resolve the same instance.
            return system.makeActor(id: id) {
                Counter(actorSystem: system)
            }
        }
        
        let port = try await system.localPort()
        
        print("========================================================")
        print("=== TicTacFish Server Running on: ws://\(port) ==")
        print("========================================================")
        

        try await Task.sleep(for: .seconds(1_000_000))
        print("Done.")
    }
}
