import Distributed
import WebSocketActors

public distributed actor Clicker {
    public typealias ActorSystem = WebSocketActorSystem
    
    var counter: Counter
    var _clicks = 0
    
    public distributed var clicks: Int {
        _clicks
    }
    
    public init(actorSystem: ActorSystem, counter: Counter) async throws {
        self.actorSystem = actorSystem
        self.counter = counter
        try await counter.register(clicker: self)
    }
    
    public distributed func click() async throws {
        try await counter.click()
    }
    
    public distributed func counterChanged(clicks: Int) {
        _clicks = clicks
    }
    
}
