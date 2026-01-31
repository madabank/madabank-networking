import Foundation
import Alamofire

public class NetworkManager: APIClientProtocol {
    
    public static let shared = NetworkManager()
    
    private let session: Session
    private var accessToken: String?
    
    // Generic error response structure
    struct ErrorResponse: Decodable {
        let message: String
    }
    
    private init() {
        // Initialize interceptor
        let interceptor = AuthInterceptor { [weak self] in
            return self?.accessToken
        }
        
        self.session = Session(interceptor: interceptor)
    }
    
    public func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    public func clearAccessToken() {
        self.accessToken = nil
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
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
    
    public func requestVoid(_ endpoint: APIEndpoint) async throws {
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
    
    private func asURLRequest(_ endpoint: APIEndpoint) throws -> URLRequestConvertible {
        if let madaEndpoint = endpoint as? MadaEndpoint {
            return madaEndpoint
        } else {
            // If it's a generic APIEndpoint, we need to construct URLRequest manually (basic support)
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
