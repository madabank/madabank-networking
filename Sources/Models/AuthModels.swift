import Foundation

// MARK: - Auth

public struct LoginRequest: Encodable {
    public let email: String
    public let password: String?
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct RegisterRequest: Encodable {
    public let email: String
    public let password: String
    public let firstName: String
    public let lastName: String
    public let phone: String
    public let dateOfBirth: String // ISO8601
    
    public init(email: String, password: String, firstName: String, lastName: String, phone: String, dateOfBirth: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.dateOfBirth = dateOfBirth
    }
    
    enum CodingKeys: String, CodingKey {
        case email, password, phone
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
    }
}

public struct RegisterResponse: Decodable {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let kycStatus: String
    public let isActive: Bool
    public let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case kycStatus = "kyc_status"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

public struct AuthResponse: Decodable {
    public let token: String
    public let refreshToken: String
    public let expiresAt: String // ISO String based on example
    public let user: UserProfile? // Optional as per example structure
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case user
    }
}

public struct RefreshTokenRequest: Encodable {
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

public struct ForgotPasswordRequest: Encodable {
    public let email: String
    public init(email: String) { self.email = email }
}

public struct ForgotPasswordResponse: Decodable {
    public let message: String
}

public struct ResetPasswordRequest: Encodable {
    public let email: String
    public let otp: String
    public let newPassword: String
    
    public init(email: String, otp: String, newPassword: String) {
        self.email = email
        self.otp = otp
        self.newPassword = newPassword
    }
    
    enum CodingKeys: String, CodingKey {
        case email, otp
        case newPassword = "new_password"
    }
}

public struct ResetPasswordResponse: Decodable {
    public let message: String
}

public struct ChangePasswordRequest: Encodable {
    public let oldPassword: String
    public let newPassword: String
    
    public init(oldPassword: String, newPassword: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
    }
    
    enum CodingKeys: String, CodingKey {
        case oldPassword = "old_password"
        case newPassword = "new_password"
    }
}

public struct ChangePasswordResponse: Decodable {
    public let message: String
}
