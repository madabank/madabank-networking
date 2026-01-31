import Foundation

public struct Card: Codable {
    public let id: String
    public let accountId: String
    public let maskedNumber: String
    public let type: CardType
    public let status: CardStatus
    public let expiryDate: String
    public let holderName: String
    public let dailyLimit: Decimal
    
    enum CodingKeys: String, CodingKey {
        case id, status, type
        case accountId = "account_id"
        case maskedNumber = "masked_number"
        case expiryDate = "expiry_date"
        case holderName = "holder_name"
        case dailyLimit = "daily_limit"
    }
}

public enum CardType: String, Codable {
    case debit
    case credit
    case virtual
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = CardType(rawValue: value) ?? .unknown
    }
}

public enum CardStatus: String, Codable {
    case active
    case blocked
    case cancelled
    case expired
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = CardStatus(rawValue: value) ?? .unknown
    }
}

public struct IssueCardRequest: Encodable {
    public let accountId: String
    public let cardHolderName: String
    public let cardType: String
    public let dailyLimit: Decimal
    
    public init(accountId: String, cardHolderName: String, cardType: String, dailyLimit: Decimal) {
        self.accountId = accountId
        self.cardHolderName = cardHolderName
        self.cardType = cardType
        self.dailyLimit = dailyLimit
    }
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case cardHolderName = "card_holder_name"
        case cardType = "card_type"
        case dailyLimit = "daily_limit"
    }
}

public struct CardDetailsRequest: Encodable {
    public let cardId: String
    public let password: String // Encrypted if E2EE is active
    
    public init(cardId: String, password: String) {
        self.cardId = cardId
        self.password = password
    }
    
    enum CodingKeys: String, CodingKey {
        case cardId = "card_id"
        case password
    }
}

public struct CardDetailsResponse: Decodable {
    public let pan: String
    public let cvv: String
    public let expiry: String
}
