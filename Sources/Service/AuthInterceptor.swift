import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    
    private let tokenProvider: () -> String?
    
    init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // Add Bearer token if available
        if let token = tokenProvider() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // TODO: Implement refresh token logic here
        // If 401, call refresh token endpoint
        // For now, do not retry
        completion(.doNotRetry)
    }
}
