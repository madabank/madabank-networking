import Foundation
import Alamofire

/// Defines all API endpoints for Madabank
public enum APIEndpoint: Endpoint {
    
    // Auth
    case login(LoginRequest)
    case register(RegisterRequest)
    case refreshToken(RefreshTokenRequest)
    case forgotPassword(ForgotPasswordRequest)
    case resetPassword(ResetPasswordRequest)
    case changePassword(ChangePasswordRequest)
    
    // User
    case getProfile
    case updateProfile(UpdateProfileRequest)
    case deleteProfile
    
    // Accounts
    case getAccounts
    case createAccount(CreateAccountRequest)
    case getAccount(id: String)
    case getAccountBalance(id: String)
    case updateAccount(id: String, status: String)
    case closeAccount(id: String)
    
    // Transactions
    case getTransactions(GetTransactionsRequest)
    case getTransaction(id: String)
    case transfer(TransferRequest)

    
    // MARK: - Properties
    
    public var path: String {
        switch self {
        case .login: return "/auth/login"
        case .register: return "/auth/register"
        case .refreshToken: return "/auth/refresh"
        case .forgotPassword: return "/auth/forgot-password"
        case .resetPassword: return "/auth/reset-password"
        case .changePassword: return "/auth/change-password"
            
        case .getProfile, .updateProfile, .deleteProfile: return "/users/profile"
            
        case .getAccounts, .createAccount: return "/accounts"
        case .getAccount(let id): return "/accounts/\(id)"
        case .getAccountBalance(let id): return "/accounts/\(id)/balance"
        case .updateAccount(let id, _): return "/accounts/\(id)"
        case .closeAccount(let id): return "/accounts/\(id)"
            
        case .getTransactions: return "/transactions/history"
        case .getTransaction(let id): return "/transactions/\(id)"
        case .transfer: return "/transactions/transfer"
        case .deposit: return "/transactions/deposit"
        case .withdraw: return "/transactions/withdraw"
        case .resolveQR: return "/transactions/qr/resolve"
            
        case .getCards, .issueCard: return "/cards"
        case .getCardDetails: return "/cards/details"
        case .updateCard(let id, _): return "/cards/\(id)"
        case .blockCard(let id): return "/cards/\(id)/block"
        case .deleteCard(let id): return "/cards/\(id)"
            
        case .getPublicKey: return "/security/public-key"
        case .getHealth: return "/health"
        case .getVersion: return "/version"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .login, .register, .refreshToken, .forgotPassword, .resetPassword, .changePassword: return .post
        case .createAccount: return .post
        case .transfer, .deposit, .withdraw, .resolveQR: return .post
        case .issueCard, .getCardDetails, .blockCard: return .post
            
        case .getProfile, .getAccounts, .getAccount, .getAccountBalance, .getTransactions, .getTransaction, .getCards, .getPublicKey, .getHealth, .getVersion: return .get
            
        case .updateProfile: return .put
        case .updateAccount: return .patch
        case .updateCard: return .patch // Added
        
        case .deleteProfile, .closeAccount, .deleteCard: return .delete
        }
    }
    
    case deposit(DepositRequest)
    case withdraw(WithdrawRequest)
    case resolveQR(ResolveQRRequest)
    
    // Cards
    case getCards(accountId: String)
    case issueCard(IssueCardRequest)
    case getCardDetails(CardDetailsRequest)
    case updateCard(id: String, request: UpdateCardRequest)
    case blockCard(id: String)
    case deleteCard(id: String)
    
    // Security / System
    case getPublicKey
    case getHealth
    case getVersion
        
    public var parameters: Parameters? {
        switch self {
        case .getTransactions(let req):
            var params: Parameters = ["account_id": req.accountId]
            if let limit = req.limit { params["limit"] = limit }
            if let offset = req.offset { params["offset"] = offset }
            if let startDate = req.startDate { params["start_date"] = startDate }
            if let endDate = req.endDate { params["end_date"] = endDate }
            if let type = req.type { params["type"] = type }
            return params
            
        case .getCards(let accountId):
            return ["account_id": accountId]
            
        default:
            return nil
        }
    }

    
    public var body: Encodable? {
        switch self {
        case .login(let req): return req
        case .register(let req): return req
        case .refreshToken(let req): return req
        case .forgotPassword(let req): return req
        case .resetPassword(let req): return req
        case .changePassword(let req): return req
            
        case .updateProfile(let req): return req
        case .createAccount(let req): return req
        case .updateAccount(_, let status): return ["status": status]
            
        case .transfer(let req): return req
        case .deposit(let req): return req
        case .withdraw(let req): return req
        case .resolveQR(let req): return req
            
        case .issueCard(let req): return req
        case .getCardDetails(let req): return req
        case .updateCard(_, let req): return req
            
        default: return nil
        }
    }
    
    public var encoding: ParameterEncoding {
        switch method {
        case .get: return URLEncoding.default
        default: return JSONEncoding.default
        }
    }
}

// Extension to help with Alamofire request creation
extension APIEndpoint: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        // Headers
        if let headers = headers {
            for (key, value) in headers.dictionary {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Body (Encodable)
        if let body = body {
            urlRequest = try JSONParameterEncoder.default.encode(body, into: urlRequest)
        }
        
        // Query Parameters (for GET)
        if let parameters = parameters {
             urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}
