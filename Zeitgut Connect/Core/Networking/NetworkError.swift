import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case authenticationRequired
    case server(statusCode: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The backend response was invalid."
        case .authenticationRequired:
            return "Your session expired. Please sign in again."
        case let .server(statusCode, body):
            return "Backend returned HTTP \(statusCode): \(body)"
        }
    }

    var isAuthenticationRequired: Bool {
        if case .authenticationRequired = self {
            return true
        }

        return false
    }
}

extension Error {
    var isAuthenticationRequired: Bool {
        (self as? NetworkError)?.isAuthenticationRequired ?? false
    }

    var isCancellationError: Bool {
        if self is CancellationError {
            return true
        }

        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
}

extension Notification.Name {
    static let authenticationRequired = Notification.Name("AuthenticationRequired")
}
