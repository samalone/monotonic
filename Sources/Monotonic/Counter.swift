import Distributed
import WebSocketActors

extension ActorIdentity {
    public static let counter: ActorIdentity = "counter"
}

public distributed actor Counter {
    public typealias ActorSystem = WebSocketActorSystem
    
    var numberOfClicks = 0
    var monitors: Set<CountMonitor> = []
    
    public init(actorSystem: ActorSystem, numberOfClicks: Int = 0) {
        actorSystem.logger.trace("Counter.init")
        self.actorSystem = actorSystem
        self.numberOfClicks = numberOfClicks
    }
    
    deinit {
        actorSystem.logger.trace("Counter.deinit")
    }
    
    public distributed func register(monitor: CountMonitor) async {
        actorSystem.logger.trace("Counter.register(\(monitor.id))")
        monitors.insert(monitor)
        
        // Immediately broadcast to the new clicker so they have the current value.
        do {
            try await monitor.counterChanged(clicks: numberOfClicks)
        }
        catch {
            actorSystem.logger.error("Broadcast error: \(error)")
        }
    }
    
    public distributed func unregister(monitor: CountMonitor) {
        actorSystem.logger.trace("Counter.unregister(\(monitor.id))")
        monitors.remove(monitor)
    }
    
    public distributed func click() async {
        actorSystem.logger.trace("Counter.click")
        numberOfClicks += 1
        await broadcastClicks(clicks: numberOfClicks)
    }
    
    func broadcastClicks(clicks: Int) async {
        actorSystem.logger.trace("broadcasting to \(monitors.count) monitors")
        await withTaskGroup(of: Void.self) { group in
            let logger = self.actorSystem.logger
            for monitor in monitors {
                group.addTask {
                    do {
                        try await monitor.counterChanged(clicks: clicks)
                    }
                    catch {
                        logger.error("Broadcast error: \(error)")
                    }
                }
            }
        }
        actorSystem.logger.trace("broadcast complete")
    }
    
}
