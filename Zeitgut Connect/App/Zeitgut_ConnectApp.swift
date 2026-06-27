//
//  Zeitgut_ConnectApp.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

@main
struct Zeitgut_ConnectApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AuthGateView(viewModel: authViewModel)
                .onOpenURL { url in
                    authViewModel.handleRedirect(url)
                }
        }
    }
}
