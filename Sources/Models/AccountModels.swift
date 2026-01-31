import Foundation

public struct AccountListResponse: Decodable {
    public let accounts: [Account]
    public let total: Int
}

public struct Account: Codable {
    public let id: String
    public let accountNumber: String? 
    public let accountType: AccountType?
    public let balance: Decimal?
    public let currency: String?
    public let status: AccountStatus?
    
    enum CodingKeys: String, CodingKey {
        case id, balance, currency, status
        case accountNumber = "account_number"
        case accountType = "account_type"
    }
}

public enum AccountType: String, Codable {
    case savings
    case checking
    case business
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = AccountType(rawValue: value) ?? .unknown
    }
}

public enum AccountStatus: String, Codable {
    case active
    case frozen
    case closed
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = AccountStatus(rawValue: value) ?? .unknown
    }
}

public struct CreateAccountRequest: Encodable {
    public let accountType: String
    public let currency: String
    
    public init(accountType: String, currency: String) {
        self.accountType = accountType
        self.currency = currency
    }
    
    enum CodingKeys: String, CodingKey {
        case accountType = "account_type"
        case currency
    }
}

public struct UpdateAccountStatusRequest: Encodable {
    public let status: String
    public init(status: String) { self.status = status }
}

public struct AccountBalance: Decodable {
    public let accountId: String
    public let accountNumber: String
    public let balance: Decimal
    public let currency: String
    public let asOfDate: String
    
    enum CodingKeys: String, CodingKey {
        case balance, currency
        case accountId = "account_id"
        case accountNumber = "account_number"
        case asOfDate = "as_of_date"
    }
}
