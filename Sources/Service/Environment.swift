import Foundation

public enum Environment {
    case prod
    case dev
    case test
    
    public static var current: Environment {
        if ProcessInfo.processInfo.arguments.contains("-TEST_MODE") {
            return .test
        } else if ProcessInfo.processInfo.arguments.contains("-DEV_MODE") {
            return .dev
        } else {
            #if targetEnvironment(simulator)
            return .dev
            #else
            return .prod
            #endif
        }
    }
    
    public var baseURL: String {
        switch self {
        case .prod:
            return "https://api.madabank.art"
        case .dev, .test:
            return "https://mock.madabank.art" // Placeholder, actually ignored when mocking
        }
    }
    
    public var isMockingEnabled: Bool {
        return self == .dev || self == .test
    }
}
