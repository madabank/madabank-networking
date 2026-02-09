import Foundation

public struct AccountListResponse: Decodable {
    public let accounts: [Account]
    public let total: Int
    
    public init(accounts: [Account], total: Int) {
        self.accounts = accounts
        self.total = total
    }
}

public struct Account: Codable {
    public let id: String
    public let accountNumber: String? 
    public let accountType: AccountType?
    public let balance: Decimal?
    public let currency: String?
    public let status: AccountStatus?
    
    public init(id: String, accountNumber: String?, accountType: AccountType?, balance: Decimal?, currency: String?, status: AccountStatus?) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.balance = balance
        self.currency = currency
        self.status = status
    }
    
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
    
    public init(accountId: String, accountNumber: String, balance: Decimal, currency: String, asOfDate: String) {
        self.accountId = accountId
        self.accountNumber = accountNumber
        self.balance = balance
        self.currency = currency
        self.asOfDate = asOfDate
    }
    
    enum CodingKeys: String, CodingKey {
        case balance, currency
        case accountId = "account_id"
        case accountNumber = "account_number"
        case asOfDate = "as_of_date"
    }
}
