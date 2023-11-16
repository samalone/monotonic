import XCTest
import Distributed
@testable import Monotonic

class TestModel: LocalModel {
    var count: Int = 0
    
    func set(count: Int) async {
        self.count = count
    }
}

final class MonotonicTests: XCTestCase {
    func testExample() async throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
        let actorSystem = try WebSocketActorSystem(mode: .serverOnly(host: "localhost", port: 8888))
        
        // Create a Counter that will store the number of clicks.
        let counter = Counter(actorSystem: actorSystem)
        
        let model1 = TestModel()
        let model2 = TestModel()
        
        let clicker1 = try await Clicker(actorSystem: actorSystem, counter: counter, model: model1)
        let clicker2 = try await Clicker(actorSystem: actorSystem, counter: counter, model: model2)
        
        try await clicker1.click()
        XCTAssertEqual(model1.count, 1)
        XCTAssertEqual(model2.count, 1)
        
        try await clicker2.click()
        XCTAssertEqual(model1.count, 2)
        XCTAssertEqual(model2.count, 2)
        
    }
}
