import XCTest
import Distributed
import WebSocketActors
import Logging
@testable import Monotonic

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
    
    func testExample() async throws {
        // Create a Counter that will store the number of clicks.
        let counter = Counter(actorSystem: server)
        
        let clicker1 = try await Clicker(actorSystem: server, counter: counter)
        let clicker2 = try await Clicker(actorSystem: server, counter: counter)
        
        try await clicker1.click()
        let c11 = try await clicker1.clicks
        XCTAssertEqual(c11, 1)
        let c21 = try await clicker1.clicks
        XCTAssertEqual(c21, 1)
        
        try await clicker2.click()
        let c12 = try await clicker1.clicks
        XCTAssertEqual(c12, 2)
        let c22 = try await clicker1.clicks
        XCTAssertEqual(c22, 2)
        
    }
    
    func testRemote() async throws {
        let counter = server.makeLocalActor(id: .counter) {
            Counter(actorSystem: server)
        }
        
        let client1 = try await WebSocketActorSystem(mode: .client(of: serverAddress))
        let client2 = try await WebSocketActorSystem(mode: .client(of: serverAddress))
        
        let counter1 = try Counter.resolve(id: .counter, using: client1)
        let clicker1 = try await Clicker(actorSystem: client1, counter: counter1)
        
        let counter2 = try Counter.resolve(id: .counter, using: client2)
        let clicker2 = try await Clicker(actorSystem: client2, counter: counter2)
        
        try await clicker1.click()

        // It will take some time for the server to update the clients with
        // the new count.
        try await Task.sleep(for: .seconds(0.5))
        
        let c11 = try await clicker1.clicks
        XCTAssertEqual(c11, 1)
        let c21 = try await clicker1.clicks
        XCTAssertEqual(c21, 1)
        
        try await clicker2.click()
        
        // It will take some time for the server to update the clients with
        // the new count.
        try await Task.sleep(for: .seconds(0.5))
        
        let c12 = try await clicker1.clicks
        XCTAssertEqual(c12, 2)
        let c22 = try await clicker1.clicks
        XCTAssertEqual(c22, 2)
    }
}
