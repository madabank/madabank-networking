import Foundation
import Alamofire
import Core

/// Token refresh interceptor that automatically refreshes expired tokens
public class TokenRefreshInterceptor: RequestInterceptor {
    
    private let tokenManager: TokenManager
    private let refreshURL: URL
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    public init(
        tokenManager: TokenManager = .shared,
        refreshURL: URL = URL(string: "https://api.madabank.art/auth/refresh")!
    ) {
        self.tokenManager = tokenManager
        self.refreshURL = refreshURL
    }
    
    // MARK: - RequestAdapter
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        // Add access token to request header
        if let token = tokenManager.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(request))
    }
    
    // MARK: - RequestRetrier
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        lock.lock()
        defer { lock.unlock() }
        
        requestsToRetry.append(completion)
        
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        refreshToken { [weak self] success in
            guard let self = self else { return }
            
            self.lock.lock()
            defer { self.lock.unlock() }
            
            self.requestsToRetry.forEach { $0(success ? .retry : .doNotRetry) }
            self.requestsToRetry.removeAll()
            self.isRefreshing = false
        }
    }
    
    // MARK: - Token Refresh
    
    private func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = tokenManager.refreshToken else {
            tokenManager.clearSession()
            completion(false)
            return
        }
        
        let parameters: [String: String] = ["refresh_token": refreshToken]
        
        AF.request(
            refreshURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        .responseDecodable(of: TokenRefreshResponse.self) { [weak self] response in
            switch response.result {
            case .success(let tokenResponse):
                self?.tokenManager.saveTokens(
                    accessToken: tokenResponse.token,
                    refreshToken: tokenResponse.refreshToken
                )
                completion(true)
                
            case .failure:
                self?.tokenManager.clearSession()
                completion(false)
            }
        }
    }
}

// MARK: - Response Model

private struct TokenRefreshResponse: Decodable {
    let token: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
    }
}
