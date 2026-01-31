import XCTest
@testable import Network

final class NetworkTests: XCTestCase {
    func testVersion() {
        XCTAssertEqual(Network.version, "1.0.0")
    }
}
