import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    func testVersion() {
        XCTAssertEqual(Network.version, "1.0.0")
    }
}
