import XCTest
import Distributed
import WebSocketActors
import Logging
@testable import Monotonic

actor Model: LocalModel {
    var count: Int = 0

    func set(count: Int) async {
        self.count = count
    }
}

final class MonotonicTests: XCTestCase {
    var logger = Logger(label: "server")
    var server: WebSocketActorSystem!
    var serverAddress = ServerAddress(scheme: .insecure, host: "localhost", port: 0)
    
    override func setUp() async throws {
        logger = Logger(label: "\(name) server")
        logger.logLevel = .trace
        server = try await WebSocketActorSystem(mode: .server(at: serverAddress),
                                                id: NodeIdentity(id: "server"),
                                                logger: logger)
        // Now that the server is started, we can find out what port number it is using.
        serverAddress = try await server.address()
    }
    
    override func tearDown() async throws {
        await server.shutdownGracefully()
    }
    
    func testLocal() async throws {
        // Create a Counter that will store the number of clicks.
        let counter = server.makeLocalActor(id: .counter) {
            Counter(actorSystem: server)
        }
        
        let model1 = Model()
        let monitor1 = server.makeLocalActor {
            CountMonitor(actorSystem: server, model: model1)
        }
        try await counter.register(monitor: monitor1)

        let model2 = Model()
        let monitor2 = server.makeLocalActor {
            CountMonitor(actorSystem: server, model: model2)
        }
        try await counter.register(monitor: monitor2)
        
        try await counter.click()
        let c11 = await model1.count
        XCTAssertEqual(c11, 1)
        let c21 = await model2.count
        XCTAssertEqual(c21, 1)
        
        try await counter.click()
        let c12 = await model1.count
        XCTAssertEqual(c12, 2)
        let c22 = await model2.count
        XCTAssertEqual(c22, 2)
        
    }
    
    func testRemote() async throws {
        // Note that makeLocalActor stores the actor in the server's actor registry,
        // so it will not be garbage collected even though we don't keep a reference
        // to it.
        _ = server.makeLocalActor(id: .counter) {
            Counter(actorSystem: server)
        }
        
        let client1 = try await WebSocketActorSystem(mode: .client(of: serverAddress))
        let client2 = try await WebSocketActorSystem(mode: .client(of: serverAddress))
        
        // This is the correct way to resolve a remote actor.
        let counter1 = try Counter.resolve(id: .counter, using: client1)
        let model1 = Model()
        let monitor1 = client1.makeLocalActor {
            CountMonitor(actorSystem: client1, model: model1)
        }
        try await counter1.register(monitor: monitor1)
        
        let counter2 = try Counter.resolve(id: .counter, using: client2)
        let model2 = Model()
        let monitor2 = client2.makeLocalActor {
            CountMonitor(actorSystem: client2, model: model2)
        }
        try await counter2.register(monitor: monitor2)
        
        try await counter1.click()
        
        let c11 = await model1.count
        XCTAssertEqual(c11, 1)
        let c21 = await model2.count
        XCTAssertEqual(c21, 1)
        
        try await counter2.click()
        
        let c12 = await model1.count
        XCTAssertEqual(c12, 2)
        let c22 = await model2.count
        XCTAssertEqual(c22, 2)
    }
}
