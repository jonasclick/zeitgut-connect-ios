//
//  StartView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

struct StartView: View {
  @Binding var session: AuthSession
  let refreshGeneration: Int
  @State private var activities: [Activity] = []
  @State private var isLoadingActivities = false
  @State private var activityError: String?
  
  private let authService = AuthService()
  private let transactionService = TransactionService()
  
  private var formattedTimeBalance: String {
    let balance = session.timeBalance ?? 0
    return "\(balance.formatted(.number.precision(.fractionLength(1))))h"
  }
  
  private var refreshTaskId: String {
    "\(session.accessToken)-\(session.userId)-\(refreshGeneration)"
  }
  
  var body: some View {
    VStack (alignment: .leading) {
      Text("Zeitgut Connect")
        .font(.largeTitle)
        .fontWeight(.bold)

      // Time Balance
      HStack {
        Text("Mein Stundensaldo")
          .font(.system(size: 20))
          .bold()
        Spacer()
        Spacer()
        Text(formattedTimeBalance)
          .font(.system(size: 20))
          .bold()
          .frame(width: 80, height: 80)
          .background(
            Capsule()
              .fill(Color.silentMint)
          )
        Spacer()
      }
      .padding(.bottom, 5)
      
      Text("Letzte Aktivitäten")
        .font(.system(size: 20))
        .bold()

      ScrollView (.vertical, showsIndicators: false) {
          VStack (spacing: 12) {
            if isLoadingActivities {
              ProgressView("Aktivitäten werden geladen...")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
            } else if let activityError {
              Text(activityError)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
            } else if activities.isEmpty {
              Text("Noch keine bestätigten Aktivitäten vorhanden.")
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
            } else {
              ForEach(activities) { activity in
                ActivityCardView(activity: activity)
              }
            }
          }
          .padding(.bottom, 75)
          Spacer(minLength: 0)
        }
    }
    .padding()
    
    .refreshable {
      await refreshContent()
    }
    .task(id: refreshTaskId) {
      await refreshContent()
    }
  }
  
  @MainActor
  private func refreshContent() async {
    guard session.accessToken.isEmpty == false, session.userId.isEmpty == false else {
      activities = []
      return
    }
    
    isLoadingActivities = true
    activityError = nil
    
    do {
      session = try await authService.refreshSession(accessToken: session.accessToken, session: session)
      let response = try await transactionService.fetchMyTransactions(accessToken: session.accessToken).value
      activities = response.transactions
        .filter { $0.status == "confirmed" }
        .map { $0.toActivity(for: session.userId) }
      activityError = nil
    } catch {
      if error.isAuthenticationRequired || error.isCancellationError {
        activityError = nil
      } else {
        activityError = error.localizedDescription
      }
    }
    
    isLoadingActivities = false
  }
  
}

#Preview {
  StartView(session: .constant(AuthSession(timeBalance: 2.6)), refreshGeneration: 0)
}
