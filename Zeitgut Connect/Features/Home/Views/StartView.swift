//
//  StartView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

struct StartView: View {
    let session: AuthSession
    @State private var activities: [Activity] = []
    @State private var isLoadingActivities = false
    @State private var activityError: String?

    private let transactionService = TransactionService()

    private var formattedTimeBalance: String {
      let balance = session.timeBalance ?? 0
      return "\(balance.formatted(.number.precision(.fractionLength(1))))h"
    }

    var body: some View {
      VStack (alignment: .leading){
        
        Text("Zeitgut Connect")
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding(.top, 5)
          .padding(.bottom, 15)
        
        // Mein Stundensaldo
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
        .padding(.bottom, 10)
        
        
        // Letzte Aktivitäten
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
        }
        .task(id: session.accessToken) {
          await loadActivities()
        }
        // Push Content to top of screen
        Spacer()
      }
      .padding()
    }

    private func loadActivities() async {
      guard session.accessToken.isEmpty == false, session.userId.isEmpty == false else {
        activities = []
        return
      }

      isLoadingActivities = true
      activityError = nil

      do {
        let response = try await transactionService.fetchMyTransactions(accessToken: session.accessToken).value
        activities = response.transactions
          .filter { $0.status == "confirmed" }
          .map { $0.toActivity(for: session.userId) }
        activityError = nil
      } catch {
        if error.isAuthenticationRequired {
          activityError = nil
        } else {
          activityError = error.localizedDescription
        }
      }

      isLoadingActivities = false
    }
}

#Preview {
    StartView(session: AuthSession(timeBalance: 2.6))
}
