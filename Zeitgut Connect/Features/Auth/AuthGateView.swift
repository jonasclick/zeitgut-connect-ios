import SwiftUI

struct AuthGateView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        Group {
            switch viewModel.phase {
            case .authenticated:
                MainContainerView(session: $viewModel.session)
            case .loading:
                loadingView
            case .signedOut:
                loginView
            case .onboarding:
                onboardingView
            }
        }
        .task {
            viewModel.start()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text(viewModel.statusText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    private var loginView: some View {
        VStack(spacing: 16) {
            Text("Zeitgut Connect")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(viewModel.statusText)
                .multilineTextAlignment(.center)

            if let errorText = viewModel.errorText {
                Text(errorText)
                    .multilineTextAlignment(.center)
            }

            Text(viewModel.resultText)
                .font(.footnote)
                .multilineTextAlignment(.center)

            Button("Sign in with Microsoft") {
                viewModel.signIn()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    private var onboardingView: some View {
        VStack(spacing: 16) {
            Text("Zeitgut Connect")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(viewModel.statusText)
                .multilineTextAlignment(.center)

            if let errorText = viewModel.errorText {
                Text(errorText)
                    .multilineTextAlignment(.center)
            }

            Text(viewModel.resultText)
                .font(.footnote)
                .multilineTextAlignment(.center)

            TextField("Invitation code", text: $viewModel.inviteCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            Button("Continue") {
                viewModel.submitInviteCode()
            }
            .disabled(viewModel.inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
