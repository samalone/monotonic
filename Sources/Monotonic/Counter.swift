import Distributed
import WebSocketActors

extension ActorIdentity {
    public static let counter: ActorIdentity = "counter"
}

public distributed actor Counter {
    public typealias ActorSystem = WebSocketActorSystem
    
    var numberOfClicks = 0
    var clickers: Set<Clicker> = []
    
    public init(actorSystem: ActorSystem, numberOfClicks: Int = 0) {
        self.actorSystem = actorSystem
        self.numberOfClicks = numberOfClicks
    }
    
    public distributed func register(clicker: Clicker) {
        clickers.insert(clicker)
    }
    
    public distributed func unregister(clicker: Clicker) {
        clickers.remove(clicker)
    }
    
    public distributed func click() async {
        numberOfClicks += 1
        await broadcastClicks(clicks: numberOfClicks)
    }
    
    func broadcastClicks(clicks: Int) async {
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
    }
    
}
