//
//  CountMonitor.swift
//
//
//  Created by Stuart A. Malone on 11/16/23.
//

import Distributed
import Foundation
import WebSocketActors

public protocol LocalModel {
    func set(count: Int) async
}

/// A distributed actor that receives an updated count from the server and
/// updates the local model on the main thread.
public distributed actor CountMonitor {
    public typealias ActorSystem = WebSocketActorSystem
    
    var model: LocalModel
    
    public init(actorSystem: ActorSystem, model: LocalModel) {
        self.actorSystem = actorSystem
        self.model = model
    }
    
    public distributed func counterChanged(clicks: Int) async {
        await model.set(count: clicks)
    }
}
