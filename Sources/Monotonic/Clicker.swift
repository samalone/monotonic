import Distributed

public protocol LocalModel {
    func set(count: Int) async
}

public distributed actor Clicker {
    public typealias ActorSystem = WebSocketActorSystem
    
    var counter: Counter
    var model: LocalModel
    
    public init(actorSystem: ActorSystem, counter: Counter, model: LocalModel) {
        self.actorSystem = actorSystem
        self.counter = counter
        self.model = model
    }
    
    public distributed func click() async throws {
        try await counter.click()
    }
    
    public distributed func counterChanged(clicks: Int) async {
        await model.set(count: clicks)
    }
}
