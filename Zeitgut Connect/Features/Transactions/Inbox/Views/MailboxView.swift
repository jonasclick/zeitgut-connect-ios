//
//  MailboxView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import SwiftUI

struct MailboxView: View {
  @Binding var session: AuthSession
  let refreshGeneration: Int
  
  @State private var activities: [Activity] = []
  @State private var isLoadingActivities = false
  @State private var activityError: String?
  @State private var mailboxReloadCounter = 0
  
  private let authService = AuthService()
  private let transactionService = TransactionService()
  
  private var refreshTaskId: String {
    "\(session.accessToken)-\(session.userId)-\(refreshGeneration)-\(mailboxReloadCounter)"
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Briefkasten")
        .font(.system(size: 28))
        .bold()
        .padding(.bottom, 10)
      
      Text("Bitte prüfe folgende Zeiterfassungen")
        .font(.system(size: 20))
        .bold()
      
      ScrollView(.vertical, showsIndicators: false) {
        
        VStack(spacing: 12) {
          if isLoadingActivities {
            ProgressView("Briefkasten wird geladen...")
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.vertical, 24)
          } else if let activityError {
            Text(activityError)
              .font(.footnote)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.vertical, 24)
          } else if activities.isEmpty {
            Text("Dein Briefkasten ist aktuell leer.")
              .font(.footnote)
              .multilineTextAlignment(.center)
              .frame(maxWidth: .infinity, alignment: .center)
              .padding(.vertical, 24)
          } else {
            ForEach(activities) { activity in
              ActivityCardView(activity: activity)
              AcceptDenyButtonsView(
                onAccept: {
                  Task {
                    await acceptActivity(activity)
                  }
                },
                onDeny: {
                  Task {
                    await denyActivity(activity)
                  }
                }
              )
              .padding(.bottom, 18)
            }
          }
        }
        .padding(.bottom, 18)
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
      let response = try await transactionService.fetchMailbox(accessToken: session.accessToken).value
      activities = response.transactions.map { $0.toActivity(for: session.userId) }
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
  
  @MainActor
  private func acceptActivity(_ activity: Activity) async {
    isLoadingActivities = true
    activityError = nil
    
    do {
      let response = try await transactionService.acceptMailboxTransaction(
        accessToken: session.accessToken,
        transactionId: activity.id
      ).value
      session.timeBalanceMinutes = response.member?.timeBalanceMinutes ?? session.timeBalanceMinutes
      mailboxReloadCounter += 1
    } catch {
      activityError = (error.isAuthenticationRequired || error.isCancellationError) ? nil : error.localizedDescription
    }
    
    isLoadingActivities = false
  }
  
  @MainActor
  private func denyActivity(_ activity: Activity) async {
    isLoadingActivities = true
    activityError = nil
    
    do {
      let response = try await transactionService.denyMailboxTransaction(
        accessToken: session.accessToken,
        transactionId: activity.id
      ).value
      session.timeBalanceMinutes = response.member?.timeBalanceMinutes ?? session.timeBalanceMinutes
      mailboxReloadCounter += 1
    } catch {
      activityError = (error.isAuthenticationRequired || error.isCancellationError) ? nil : error.localizedDescription
    }
    
    isLoadingActivities = false
  }
}

#Preview {
  MailboxView(session: .constant(AuthSession()), refreshGeneration: 0)
}
