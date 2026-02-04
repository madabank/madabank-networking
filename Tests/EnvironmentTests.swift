import XCTest
@testable import Networking

final class EnvironmentTests: XCTestCase {
    
    func testProdEnvironment() {
        let sut = Environment.prod
        XCTAssertEqual(sut.baseURL, "https://api.madabank.art")
        XCTAssertFalse(sut.isMockingEnabled)
    }
    
    func testDevEnvironment() {
        let sut = Environment.dev
        XCTAssertEqual(sut.baseURL, "https://mock.madabank.art")
        XCTAssertTrue(sut.isMockingEnabled)
    }
    
    func testTestEnvironment() {
        let sut = Environment.test
        XCTAssertEqual(sut.baseURL, "https://mock.madabank.art")
        XCTAssertTrue(sut.isMockingEnabled)
    }
    
    func testMockResponseProvider() {
        let provider = MockResponseProvider()
        // Test a few known endpoints
        XCTAssertNotNil(provider.mockData(for: APIEndpoint.login(LoginRequest(email: "a", password: "b"))), "Login mock should populate")
        XCTAssertNotNil(provider.mockData(for: APIEndpoint.getAccounts), "Accounts mock should populate")
        XCTAssertNotNil(provider.mockData(for: APIEndpoint.getHealth), "Health mock should populate")
    }
}
