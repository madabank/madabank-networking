import Foundation
import Alamofire

public class NetworkManager: APIClientProtocol {
    
    public static let shared = NetworkManager()
    
    private lazy var session: Session = {
        let interceptor = AuthInterceptor { [weak self] in
            self?.accessToken
        }
        return Session(interceptor: interceptor)
    }()
    
    private var accessToken: String?
    
    // Generic error response structure
    struct ErrorResponse: Decodable {
        let message: String
    }
    
    private init() {}
    
    public func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    public func clearAccessToken() {
        self.accessToken = nil
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try asURLRequest(endpoint)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(request)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        self.handleError(response.data, error: error, statusCode: response.response?.statusCode, continuation: continuation)
                    }
                }
        }
    }
    
    public func requestVoid(_ endpoint: Endpoint) async throws {
        let request = try asURLRequest(endpoint)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(request)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        self.handleError(response.data, error: error, statusCode: response.response?.statusCode, continuation: continuation)
                    }
                }
        }
    }
    
    private func asURLRequest(_ endpoint: Endpoint) throws -> URLRequestConvertible {
        if let apiEndpoint = endpoint as? APIEndpoint {
            return apiEndpoint
        } else {
            // If it's a generic Endpoint, we need to construct URLRequest manually (basic support)
             throw APIError.invalidURL
        }
    }
    
    private func handleError<T>(_ data: Data?, error: Error, statusCode: Int?, continuation: CheckedContinuation<T, Error>) {
         if let data = data,
           let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            continuation.resume(throwing: APIError.serverError(statusCode: statusCode ?? 500, message: errorResponse.message))
        } else {
            continuation.resume(throwing: APIError.networkError(error))
        }
    }
}
