import Foundation

public struct UserProfile: Codable {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let phone: String
    public let kycStatus: KYCStatus
    public let joinDate: Date
    
    public var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, phone
        case firstName = "first_name"
        case lastName = "last_name"
        case kycStatus = "kyc_status"
        case joinDate = "join_date"
    }
}

public enum KYCStatus: String, Codable {
    case pending
    case verified
    case rejected
    case unknown
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = KYCStatus(rawValue: value) ?? .unknown
    }
}

public struct UpdateProfileRequest: Encodable {
    public let firstName: String?
    public let lastName: String?
    public let phone: String?
    public let email: String?
    public let avatarUrl: String?
    
    public init(firstName: String? = nil, lastName: String? = nil, phone: String? = nil, email: String? = nil, avatarUrl: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        self.avatarUrl = avatarUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
        case email
        case avatarUrl = "avatar_url"
    }
}
