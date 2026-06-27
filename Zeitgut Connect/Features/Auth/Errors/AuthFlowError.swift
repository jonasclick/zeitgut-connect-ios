import Foundation

enum AuthFlowError: LocalizedError {
    case missingApplicationContext
    case missingPresentationContext
    case missingMSALResult

    var errorDescription: String? {
        switch self {
        case .missingApplicationContext:
            return "MSAL application context was not initialized."
        case .missingPresentationContext:
            return "No active iOS view controller was available to present Microsoft sign-in."
        case .missingMSALResult:
            return "Microsoft sign-in completed without a result or error."
        }
    }
}
