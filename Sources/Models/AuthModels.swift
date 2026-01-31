import Foundation

// MARK: - Auth

public struct LoginRequest: Encodable {
    public let email: String
    public let password: String? // Optional if using biometrics later, but usually required
    
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
}

public struct AuthResponse: Decodable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
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

public struct ResetPasswordRequest: Encodable {
    public let email: String
    public let otp: String
    public let newPassword: String
    
    public init(email: String, otp: String, newPassword: String) {
        self.email = email
        self.otp = otp
        self.newPassword = newPassword
    }
}
