import Foundation

public protocol MockResponseProviderProtocol {
    func mockData(for endpoint: Endpoint) -> Data?
}

public class MockResponseProvider: MockResponseProviderProtocol {
    
    public init() {}
    
    public func mockData(for endpoint: Endpoint) -> Data? {
        guard let apiEndpoint = endpoint as? APIEndpoint else { return nil }
        
        let filename: String
        
        switch apiEndpoint {
        case .login: filename = "login"
        case .register: filename = "register"
        case .refreshToken: filename = "refresh_token"
        case .getProfile: filename = "profile"
        case .getAccounts: filename = "accounts"
        case .getAccount: filename = "account_details"
        case .getAccountBalance: filename = "account_balance"
        case .getTransactions: filename = "transactions"
        case .getTransaction: filename = "transaction_details"
        case .transfer: filename = "transfer_success"
        case .getCards: filename = "cards"
        case .getPublicKey: filename = "public_key"
        case .getHealth: filename = "health"
        case .getVersion: filename = "version"
        default: return nil // Fallback or handle specific cases
        }
        
        return loadJSON(filename: filename)
    }
    
    private func loadJSON(filename: String) -> Data? {
        let bundle = Bundle(for: MockResponseProvider.self)
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            print("MockResponseProvider: File \(filename).json not found in Bundle.")
            return nil
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            print("MockResponseProvider: Failed to load \(filename).json - \(error)")
            return nil
        }
    }
}
