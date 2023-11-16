//
//  File.swift
//  
//
//  Created by Stuart A. Malone on 10/30/23.
//

import Foundation
import Distributed
import Monotonic

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
    
    static func main() {
        let system = try! WebSocketActorSystem(mode: .serverOnly(host: "0.0.0.0", port: 8888))
        
        system.registerOnDemandResolveHandler { id in
            // We create new BotPlayers "ad-hoc" as they are requested for.
            // Subsequent resolves are able to resolve the same instance.
            if system.isSharedCounterID(id) {
                return system.makeActorWithID(id) {
                    Counter(actorSystem: system)
                }
//                return system.makeActorWithID(id) {
//                    OnlineBotPlayer(team: .rodents, actorSystem: system)
//                }
            }
            
            return nil // don't resolve on-demand
        }
        
        print("========================================================")
        print("=== TicTacFish Server Running on: ws://\(system.host):\(system.port) ==")
        print("========================================================")
        
        Thread.sleep(forTimeInterval: 100_000)
        print("Done.")
    }
}
