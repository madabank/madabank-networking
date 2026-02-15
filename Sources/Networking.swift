import Foundation
import Alamofire

/// Network module for Madabank iOS
/// Contains API client, request/response handling, and token management
public enum Network {
    public static let version = "1.0.0"
}

// MARK: - API Error

public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case notFound
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "Unknown error")"
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .notFound:
            return "Resource not found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - API Client Protocol

public protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func requestVoid(_ endpoint: Endpoint) async throws
}

// MARK: - API Endpoint Protocol

public typealias URLRequestConvertible = Alamofire.URLRequestConvertible

public protocol Endpoint: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var body: Encodable? { get }
    var encoding: ParameterEncoding { get }
}

public extension Endpoint {
    var baseURL: String {
        Environment.current.baseURL
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var parameters: Parameters? {
        nil
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}

// MARK: - HTTP Method (re-export)
public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias Parameters = Alamofire.Parameters
public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias URLEncoding = Alamofire.URLEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias JSONParameterEncoder = Alamofire.JSONParameterEncoder

// MARK: - Endpoint Extension
public extension Endpoint {
    func asURLRequest() throws -> URLRequest {
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
            // Note: This relies on Swift's opened existentials or Alamofire support for Encodable existential
            urlRequest = try JSONParameterEncoder.default.encode(AnyEncodable(body), into: urlRequest)
        }
        
        // Query Parameters (for GET)
        if let parameters = parameters {
             urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}

// Helper wrapper for Encodable existential
struct AnyEncodable: Encodable {
    let value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

// Ensure Endpoint inherits URLRequestConvertible
public extension Endpoint {
    // Already conformed via extension method, but protocol inheritance is better
}
