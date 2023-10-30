import XCTest
import Distributed
@testable import Monotonic

final class MonotonicTests: XCTestCase {
    func testExample() async throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
        let actorSystem = try WebSocketActorSystem(mode: .serverOnly(host: "localhost", port: 8888))
        
        // Create a Counter that will store the number of clicks.
        let counter = Counter(actorSystem: actorSystem)
        
        let clicker1 = try await Clicker(actorSystem: actorSystem, counter: counter)
        let clicker2 = try await Clicker(actorSystem: actorSystem, counter: counter)
        
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
}
