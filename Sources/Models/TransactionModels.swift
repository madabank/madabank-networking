import Foundation

public struct Transaction: Codable {
    public let id: String
    public let fromAccountId: String?
    public let toAccountId: String?
    public let amount: Decimal
    public let currency: String
    public let type: TransactionType
    public let status: TransactionStatus
    public let description: String?
    public let date: Date
    public let idempotencyKey: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, currency, type, status, description, date
        case fromAccountId = "from_account_id"
        case toAccountId = "to_account_id"
        case idempotencyKey = "idempotency_key"
    }
}

public enum TransactionType: String, Codable {
    case transfer
    case deposit
    case withdrawal
    case payment
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = .unknown // Default
        if let type = TransactionType(rawValue: value) {
            self = type
        }
    }
}

public enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
    case cancelled
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = TransactionStatus(rawValue: value) ?? .unknown
    }
}

public struct TransactionListResponse: Decodable {
    public let transactions: [Transaction]
    public let total: Int
    public let limit: Int
    public let offset: Int
}

public struct TransferRequest: Encodable {
    public let fromAccountId: String
    public let toAccountId: String
    public let amount: Decimal
    public let description: String?
    public let idempotencyKey: String
    
    public init(fromAccountId: String, toAccountId: String, amount: Decimal, description: String?, idempotencyKey: String) {
        self.fromAccountId = fromAccountId
        self.toAccountId = toAccountId
        self.amount = amount
        self.description = description
        self.idempotencyKey = idempotencyKey
    }
    
    enum CodingKeys: String, CodingKey {
        case amount, description
        case fromAccountId = "from_account_id"
        case toAccountId = "to_account_id"
        case idempotencyKey = "idempotency_key"
    }
}

public struct DepositRequest: Encodable {
    public let accountId: String
    public let amount: Decimal
    public let idempotencyKey: String
    
    public init(accountId: String, amount: Decimal, idempotencyKey: String) {
        self.accountId = accountId
        self.amount = amount
        self.idempotencyKey = idempotencyKey
    }
    
    enum CodingKeys: String, CodingKey {
        case amount
        case accountId = "account_id"
        case idempotencyKey = "idempotency_key"
    }
}

public struct WithdrawRequest: Encodable {
    public let accountId: String
    public let amount: Decimal
    public let idempotencyKey: String
    
    public init(accountId: String, amount: Decimal, idempotencyKey: String) {
        self.accountId = accountId
        self.amount = amount
        self.idempotencyKey = idempotencyKey
    }
    
    enum CodingKeys: String, CodingKey {
        case amount
        case accountId = "account_id"
        case idempotencyKey = "idempotency_key"
    }
}

public struct ResolveQRRequest: Encodable {
    public let qrCode: String
    public init(qrCode: String) { self.qrCode = qrCode }
    
    enum CodingKeys: String, CodingKey {
        case qrCode = "qr_code"
    }
}

public struct QRResolutionResponse: Decodable {
    public let accountId: String
    public let ownerName: String
    public let currency: String
    
    enum CodingKeys: String, CodingKey {
        case currency
        case accountId = "account_id"
        case ownerName = "owner_name"
    }
}
