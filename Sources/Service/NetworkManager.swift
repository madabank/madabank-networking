import Foundation
import Alamofire

public final class NetworkManager: APIClientProtocol, @unchecked Sendable {
    
    public static let shared = NetworkManager()
    
    private lazy var session: Session = {
        let interceptor = AuthInterceptor { [weak self] in
            self?.accessToken
        }
        return Session(interceptor: interceptor)
    }()
    
    private var _accessToken: String?
    private let lock = NSLock()
    
    public var accessToken: String? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _accessToken
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _accessToken = newValue
        }
    }
    
    private let mockProvider: MockResponseProviderProtocol = MockResponseProvider()
    
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
        // Mocking Interception
        let arguments = ProcessInfo.processInfo.arguments
        let isUITesting = arguments.contains("--uitesting")
        let isMockingDisabled = arguments.contains("--disable-mocking")
        
        // Priority: 
        // 1. Force Disable (for real backend test on sim)
        // 2. Force Enable (for UI test)
        // 3. Environment default
        
        let shouldMock: Bool
        if isMockingDisabled {
            shouldMock = false
        } else if isUITesting {
            shouldMock = true
        } else {
            shouldMock = Environment.current.isMockingEnabled
        }
        
        if shouldMock {
            if let data = mockProvider.mockData(for: endpoint) {
                // Simulate network delay (reduced for tests)
                if !isUITesting {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: data)
                } catch {
                    debugPrint("NetworkManager: Mock Decoding Error for \(T.self): \(error)")
                    throw APIError.decodingError(error)
                }
            } else {
                 debugPrint("NetworkManager: Mock data not found for endpoint: \(endpoint)")
                 // Fallback or error if mock not found
                 throw APIError.networkError(NSError(domain: "NetworkManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Mock data not found"]))
            }
        }
        
        let request = try asURLRequest(endpoint)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(request)
                .validate()
                .responseDecodable(of: T.self) { [weak self] response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        self?.handleError(response.data, error: error, statusCode: response.response?.statusCode, continuation: continuation)
                    }
                }
        }
    }
    
    public func requestVoid(_ endpoint: Endpoint) async throws {
        // Mocking Interception
        let arguments = ProcessInfo.processInfo.arguments
        let isUITesting = arguments.contains("--uitesting")
        let isMockingDisabled = arguments.contains("--disable-mocking")
        
        let shouldMock: Bool
        if isMockingDisabled {
            shouldMock = false
        } else if isUITesting {
             shouldMock = true
        } else {
            shouldMock = Environment.current.isMockingEnabled
        }

        if shouldMock {
             // For void requests, existence of mock data (or just success) is enough
             // We can check if we have a mock file for it if we want to simulate success/failure
             // For now, let's assume success if we are in mock mode for void requests, or check provider
             if mockProvider.mockData(for: endpoint) != nil {
                 if !isUITesting {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                 }
                 return
             }
             // Fallthrough or return success? Let's return success for now for simple void mocks
             if !isUITesting {
                try? await Task.sleep(nanoseconds: 500_000_000)
             }
             return
        }
        
        let request = try asURLRequest(endpoint)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(request)
                .validate()
                .response { [weak self] response in
                    switch response.result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        self?.handleError(response.data, error: error, statusCode: response.response?.statusCode, continuation: continuation)
                    }
                }
        }
    }
    
    private func asURLRequest(_ endpoint: Endpoint) throws -> URLRequestConvertible {
        // Since Endpoint now conforms to URLRequestConvertible, we can just return it.
        // This bypasses the casting issue (APIError error 0) where APIEndpoint might not match.
        endpoint
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
