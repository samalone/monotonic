import Distributed

public distributed actor Counter {
    public typealias ActorSystem = WebSocketActorSystem
    
    var numberOfClicks = 0
    var clickers: Set<Clicker> = []
    
    public init(actorSystem: ActorSystem, numberOfClicks: Int = 0) {
        self.actorSystem = actorSystem
        self.numberOfClicks = numberOfClicks
        log("Counter", "init")
    }
    
    deinit {
        log("Counter", "deinit")
    }
    
    public distributed func register(clicker: Clicker) async {
        log("Counter", "register \(clicker.id)")
        clickers.insert(clicker)
        
        // Immediately broadcast to the new clicker so they have the current value.
        do {
            try await clicker.counterChanged(clicks: numberOfClicks)
        }
        catch {
            print("Broadcast error: \(error)")
        }
    }
    
    public distributed func unregister(clicker: Clicker) {
        log("Counter", "unregister \(clicker.id)")
        clickers.remove(clicker)
    }
    
    public distributed func click() async {
        log("Counter", "received click")
        numberOfClicks += 1
        await broadcastClicks(clicks: numberOfClicks)
    }
    
    func broadcastClicks(clicks: Int) async {
        log("Counter", "broadcasting to \(clickers.count) clickers")
        await withTaskGroup(of: Void.self) { group in
            for clicker in clickers {
                group.addTask {
                    do {
                        try await clicker.counterChanged(clicks: clicks)
                    }
                    catch {
                        print("Broadcast error: \(error)")
                    }
                }
            }
        }
        log("Counter", "broadcast complete")
    }
    
}
