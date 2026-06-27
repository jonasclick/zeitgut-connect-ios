import Combine
import Foundation
import MSAL
import OSLog
import SwiftUI
import UIKit

private let authLogger = Logger(subsystem: "com.github.jonasclick.zeitgutconnect", category: "ZeitgutAuth")

@MainActor
final class AuthViewModel: ObservableObject {
    enum Phase {
        case loading
        case signedOut
        case onboarding
        case authenticated
    }

    @Published var phase: Phase = .loading
    @Published var statusText = "Starting Microsoft sign-in..."
    @Published var errorText: String?
    @Published var resultText = "Waiting for sign-in"
    @Published var inviteCode = ""
    @Published private(set) var session = AuthSession()

    private let api = AuthAPI()
    private let clientId = "1ef99cf2-66c2-4f68-986b-81fb2b1e6a9f"
    private let redirectUri = "msauth.com.github.jonasclick.zeitgutconnect://auth"
    private let authorityURL = URL(string: "https://login.microsoftonline.com/common")!
    private let scopes = ["api://5363c539-7d42-4566-b2eb-83f636111c20/user_impersonation"]

    private var applicationContext: MSALPublicClientApplication?
    private var didConfigureMSALLogging = false

    func start() {
        authLogger.debug("MSAL_STEP_1 auth gate started")
        Task {
            await initializeIfNeeded()
        }
    }

    func handleRedirect(_ url: URL) {
        authLogger.debug("MSAL_STEP_1 redirect received url=\(url.absoluteString, privacy: .public)")
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
    }

    func signIn() {
        Task {
            await signInInteractively()
        }
    }

    func submitInviteCode() {
        Task {
            await joinAssociation()
        }
    }

    private func initializeIfNeeded() async {
        guard applicationContext == nil else {
            authLogger.debug("MSAL_STEP_1 application context already initialized")
            return
        }

        configureMSALLoggingIfNeeded()

        do {
            authLogger.debug("MSAL_STEP_1 initializing MSAL clientId=\(self.clientId, privacy: .public) redirectUri=\(self.redirectUri, privacy: .public)")
            let authority = try MSALAADAuthority(url: authorityURL)
            let configuration = MSALPublicClientApplicationConfig(clientId: clientId, redirectUri: redirectUri, authority: authority)
            applicationContext = try MSALPublicClientApplication(configuration: configuration)
            statusText = "Trying silent sign-in..."
            try await restoreSessionSilently()
        } catch {
            authLogger.error("MSAL_STEP_1 initialization failed error=\(Self.describe(error), privacy: .public)")
            phase = .signedOut
            statusText = "Tap to sign in."
            errorText = Self.describe(error)
        }
    }

    private func configureMSALLoggingIfNeeded() {
        guard didConfigureMSALLogging == false else {
            return
        }

        didConfigureMSALLogging = true
        MSALGlobalConfig.loggerConfig.logLevel = .verbose
        MSALGlobalConfig.loggerConfig.setLogCallback { level, message, containsPII in
            guard containsPII == false, let message else {
                return
            }

            authLogger.debug("MSAL_INTERNAL level=\(String(describing: level), privacy: .public) message=\(message, privacy: .public)")
        }
    }

    private func restoreSessionSilently() async throws {
        guard let applicationContext else {
            authLogger.error("MSAL_STEP_1 silent sign-in aborted: missing application context")
            return
        }

        let accounts = try applicationContext.allAccounts()
        authLogger.debug("MSAL_STEP_1 cached account count=\(accounts.count)")
        guard let account = accounts.first else {
            phase = .signedOut
            statusText = "Tap to sign in."
            resultText = "No cached account found."
            authLogger.debug("MSAL_STEP_1 no cached account found")
            return
        }

        do {
            authLogger.debug("MSAL_STEP_1 attempting silent token acquisition username=\(account.username ?? "unknown", privacy: .public)")
            let result = try await acquireTokenSilently(account: account)
            try await validateBackendSession(authenticationResult: result)
        } catch {
            authLogger.error("MSAL_STEP_1 silent token acquisition failed error=\(error.localizedDescription, privacy: .public)")
            phase = .signedOut
            statusText = "Tap to sign in."
            errorText = error.localizedDescription
            resultText = "Silent sign-in unavailable."
        }
    }

    private func signInInteractively() async {
        errorText = nil
        statusText = "Opening Microsoft sign-in..."
        resultText = "Waiting for Microsoft sign-in."
        phase = .loading
        authLogger.debug("MSAL_STEP_1 interactive sign-in requested")

        do {
            guard let applicationContext else {
                authLogger.error("MSAL_STEP_1 interactive sign-in missing application context")
                throw AuthAPIError.missingApplicationContext
            }
            guard let viewController = Self.topViewController() else {
                authLogger.error("MSAL_STEP_1 interactive sign-in missing presentation view controller")
                throw AuthAPIError.missingPresentationContext
            }

            authLogger.debug("MSAL_STEP_1 presenting interactive sign-in")
            let webParameters = MSALWebviewParameters(authPresentationViewController: viewController)
            let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webParameters)
            parameters.promptType = .selectAccount

            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MSALResult, Error>) in
                applicationContext.acquireToken(with: parameters) { result, error in
                    if let error {
                        authLogger.error("MSAL_STEP_1 interactive completion error=\(error.localizedDescription, privacy: .public)")
                        continuation.resume(throwing: error)
                    } else if let result {
                        authLogger.debug("MSAL_STEP_1 interactive success username=\(result.account.username ?? "unknown", privacy: .public) tokenLength=\(result.accessToken.count)")
                        continuation.resume(returning: result)
                    } else {
                        authLogger.error("MSAL_STEP_1 interactive completion returned nil result and nil error")
                        continuation.resume(throwing: AuthAPIError.missingMSALResult)
                    }
                }
            }

            try await validateBackendSession(authenticationResult: result)
        } catch {
            authLogger.error("MSAL_STEP_1 interactive sign-in failed error=\(error.localizedDescription, privacy: .public)")
            phase = .signedOut
            statusText = "Sign-in failed."
            errorText = error.localizedDescription
            resultText = "Microsoft sign-in did not complete."
        }
    }

    private func acquireTokenSilently(account: MSALAccount) async throws -> MSALResult {
        guard let applicationContext else {
            throw AuthAPIError.missingApplicationContext
        }

        let parameters = MSALSilentTokenParameters(scopes: scopes, account: account)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MSALResult, Error>) in
            applicationContext.acquireTokenSilent(with: parameters) { result, error in
                if let error {
                    authLogger.error("MSAL_STEP_1 silent completion error=\(error.localizedDescription, privacy: .public)")
                    continuation.resume(throwing: error)
                } else if let result {
                    authLogger.debug("MSAL_STEP_1 silent success username=\(result.account.username ?? "unknown", privacy: .public) tokenLength=\(result.accessToken.count)")
                    continuation.resume(returning: result)
                } else {
                    authLogger.error("MSAL_STEP_1 silent completion returned nil result and nil error")
                    continuation.resume(throwing: AuthAPIError.missingMSALResult)
                }
            }
        }
    }

    private func validateBackendSession(authenticationResult: MSALResult) async throws {
        statusText = "Validating backend session..."
        resultText = "Account: \(authenticationResult.account.username ?? "Unknown")"
        authLogger.debug("MSAL_STEP_2 calling /api/me username=\(authenticationResult.account.username ?? "unknown", privacy: .public) tokenLength=\(authenticationResult.accessToken.count)")

        let (meResponse, rawJson) = try await api.fetchMe(accessToken: authenticationResult.accessToken)
        authLogger.debug("MSAL_STEP_2 /api/me success body=\(rawJson, privacy: .public)")
        let hydratedSession = AuthSession(
            isLoggedIn: meResponse.isAssigned,
            accessToken: authenticationResult.accessToken,
            displayName: meResponse.member?.name ?? meResponse.displayName ?? authenticationResult.account.username ?? "",
            email: meResponse.member?.email ?? meResponse.email ?? authenticationResult.account.username ?? "",
            tenantId: meResponse.member?.tenantId ?? meResponse.tenantId ?? meResponse.principal?.claimValue("tenantId", "http://schemas.microsoft.com/identity/claims/tenantid") ?? "",
            userId: meResponse.member?.id ?? meResponse.userId ?? meResponse.principal?.claimValue("http://schemas.microsoft.com/identity/claims/objectidentifier", "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier") ?? "",
            timeBalance: meResponse.member?.timeBalance,
            principalJson: rawJson
        )

        session = hydratedSession

        if meResponse.isAssigned {
            authLogger.debug("MSAL_STEP_2 assigned user tenantId=\(hydratedSession.tenantId, privacy: .public) userId=\(hydratedSession.userId, privacy: .public)")
            phase = .authenticated
            statusText = "Backend session validated."
            resultText = "Account: \(hydratedSession.email)\n/api/me reached successfully."
        } else {
            authLogger.debug("MSAL_STEP_2 onboarding required userId=\(hydratedSession.userId, privacy: .public)")
            phase = .onboarding
            statusText = "Invitation code required."
            resultText = "Account: \(hydratedSession.email)\nEnter your invitation code to continue."
        }
    }

    private func joinAssociation() async {
        let normalizedInviteCode = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedInviteCode.isEmpty == false else {
            errorText = "Please enter an invitation code."
            authLogger.error("MSAL_STEP_3 join aborted: empty invite code")
            return
        }

        errorText = nil
        phase = .loading
        statusText = "Joining association..."
        resultText = "Account: \(session.email)\nSubmitting invitation code."
        authLogger.debug("MSAL_STEP_3 calling /api/me/join inviteCode=\(normalizedInviteCode, privacy: .public)")

        do {
            let (joinResponse, rawJson) = try await api.joinAssociation(accessToken: session.accessToken, inviteCode: normalizedInviteCode)
            authLogger.debug("MSAL_STEP_3 /api/me/join success body=\(rawJson, privacy: .public)")
            session.tenantId = joinResponse.tenantId ?? joinResponse.member?.tenantId ?? session.tenantId
            session.displayName = joinResponse.member?.name ?? session.displayName
            session.email = joinResponse.member?.email ?? session.email
            session.timeBalance = joinResponse.member?.timeBalance ?? session.timeBalance
            session.principalJson = rawJson
            session.isLoggedIn = joinResponse.isAssigned
            inviteCode = ""
            phase = .authenticated
            statusText = "Association joined."
            resultText = "Account: \(session.email)\nInvitation code accepted."
        } catch {
            authLogger.error("MSAL_STEP_3 /api/me/join failure error=\(error.localizedDescription, privacy: .public)")
            phase = .onboarding
            statusText = "Invitation code failed."
            errorText = error.localizedDescription
            resultText = "Account: \(session.email)\nInvitation code was rejected."
        }
    }

    private static func topViewController() -> UIViewController? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        authLogger.debug("MSAL_STEP_1 active scene count=\(connectedScenes.count)")

        let rootViewController = connectedScenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

        if rootViewController == nil {
            authLogger.error("MSAL_STEP_1 no key window root view controller found")
        }

        return topViewController(from: rootViewController)
    }

    private static func topViewController(from rootViewController: UIViewController?) -> UIViewController? {
        if let navigationController = rootViewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }

        if let tabBarController = rootViewController as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }

        if let presentedViewController = rootViewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        }

        return rootViewController
    }

    private static func describe(_ error: Error) -> String {
        let nsError = error as NSError
        let userInfo = nsError.userInfo
            .map { "\($0.key)=\($0.value)" }
            .sorted()
            .joined(separator: ", ")

        if userInfo.isEmpty {
            return "\(nsError.domain) code=\(nsError.code) description=\(nsError.localizedDescription)"
        }

        return "\(nsError.domain) code=\(nsError.code) description=\(nsError.localizedDescription) userInfo={\(userInfo)}"
    }
}
