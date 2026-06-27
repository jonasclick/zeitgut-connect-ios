import Combine
import Foundation
import MSAL
import SwiftUI
import UIKit

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

    func start() {
        Task {
            await initializeIfNeeded()
        }
    }

    func handleRedirect(_ url: URL) {
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
            return
        }

        do {
            let authority = try MSALAADAuthority(url: authorityURL)
            let configuration = MSALPublicClientApplicationConfig(clientId: clientId, redirectUri: redirectUri, authority: authority)
            applicationContext = try MSALPublicClientApplication(configuration: configuration)
            statusText = "Trying silent sign-in..."
            try await restoreSessionSilently()
        } catch {
            phase = .signedOut
            statusText = "Tap to sign in."
            errorText = error.localizedDescription
        }
    }

    private func restoreSessionSilently() async throws {
        guard let applicationContext else {
            return
        }

        let accounts = try applicationContext.allAccounts()
        guard let account = accounts.first else {
            phase = .signedOut
            statusText = "Tap to sign in."
            resultText = "No cached account found."
            return
        }

        do {
            let result = try await acquireTokenSilently(account: account)
            try await validateBackendSession(authenticationResult: result)
        } catch {
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

        do {
            guard let applicationContext else {
                throw AuthAPIError.invalidResponse
            }
            guard let viewController = Self.topViewController() else {
                throw AuthAPIError.invalidResponse
            }

            let webParameters = MSALWebviewParameters(authPresentationViewController: viewController)
            let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webParameters)
            parameters.promptType = .selectAccount

            let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MSALResult, Error>) in
                applicationContext.acquireToken(with: parameters) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let result {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwing: AuthAPIError.invalidResponse)
                    }
                }
            }

            try await validateBackendSession(authenticationResult: result)
        } catch {
            phase = .signedOut
            statusText = "Sign-in failed."
            errorText = error.localizedDescription
            resultText = "Microsoft sign-in did not complete."
        }
    }

    private func acquireTokenSilently(account: MSALAccount) async throws -> MSALResult {
        guard let applicationContext else {
            throw AuthAPIError.invalidResponse
        }

        let parameters = MSALSilentTokenParameters(scopes: scopes, account: account)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MSALResult, Error>) in
            applicationContext.acquireTokenSilent(with: parameters) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthAPIError.invalidResponse)
                }
            }
        }
    }

    private func validateBackendSession(authenticationResult: MSALResult) async throws {
        statusText = "Validating backend session..."
        resultText = "Account: \(authenticationResult.account.username ?? "Unknown")"

        let (meResponse, rawJson) = try await api.fetchMe(accessToken: authenticationResult.accessToken)
        let hydratedSession = AuthSession(
            isLoggedIn: meResponse.isAssigned,
            accessToken: authenticationResult.accessToken,
            displayName: meResponse.displayName ?? authenticationResult.account.username ?? "",
            email: meResponse.email ?? authenticationResult.account.username ?? "",
            tenantId: meResponse.tenantId ?? meResponse.principal?.claimValue("tenantId", "http://schemas.microsoft.com/identity/claims/tenantid") ?? "",
            userId: meResponse.userId ?? meResponse.principal?.claimValue("http://schemas.microsoft.com/identity/claims/objectidentifier", "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier") ?? "",
            principalJson: rawJson
        )

        session = hydratedSession

        if meResponse.isAssigned {
            phase = .authenticated
            statusText = "Backend session validated."
            resultText = "Account: \(hydratedSession.email)\n/api/me reached successfully."
        } else {
            phase = .onboarding
            statusText = "Invitation code required."
            resultText = "Account: \(hydratedSession.email)\nEnter your invitation code to continue."
        }
    }

    private func joinAssociation() async {
        let normalizedInviteCode = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedInviteCode.isEmpty == false else {
            errorText = "Please enter an invitation code."
            return
        }

        errorText = nil
        phase = .loading
        statusText = "Joining association..."
        resultText = "Account: \(session.email)\nSubmitting invitation code."

        do {
            let (joinResponse, rawJson) = try await api.joinAssociation(accessToken: session.accessToken, inviteCode: normalizedInviteCode)
            session.tenantId = joinResponse.tenantId ?? joinResponse.member?.tenantId ?? session.tenantId
            session.displayName = joinResponse.member?.name ?? session.displayName
            session.email = joinResponse.member?.email ?? session.email
            session.principalJson = rawJson
            session.isLoggedIn = joinResponse.isAssigned
            inviteCode = ""
            phase = .authenticated
            statusText = "Association joined."
            resultText = "Account: \(session.email)\nInvitation code accepted."
        } catch {
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

        let rootViewController = connectedScenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

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
}
