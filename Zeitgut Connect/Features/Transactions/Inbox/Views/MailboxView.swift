//
//  MailboxView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import SwiftUI

struct MailboxView: View {
    @Binding var session: AuthSession

    @State private var activities: [Activity] = []
    @State private var isLoadingActivities = false
    @State private var activityError: String?
    @State private var mailboxReloadCounter = 0

    private let transactionService = TransactionService()

    var body: some View {
      VStack(alignment: .leading) {
        Text("Briefkasten")
          .font(.system(size: 28))
          .bold()
          .padding(.bottom, 10)

        Text("Bitte prüfe folgende Transaktionen")
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
              Text("Im Briefkasten liegen gerade keine offenen Anfragen.")
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
        }

        Spacer()
      }
      .padding()
      .task(id: mailboxTaskId) {
        await loadActivities()
      }
    }

    private var mailboxTaskId: String {
      "\(session.accessToken)-\(mailboxReloadCounter)"
    }

    private func loadActivities() async {
      guard session.accessToken.isEmpty == false, session.userId.isEmpty == false else {
        activities = []
        return
      }

      isLoadingActivities = true
      activityError = nil

      do {
        let response = try await transactionService.fetchMailbox(accessToken: session.accessToken).value
        activities = response.transactions.map { $0.toActivity(for: session.userId) }
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

    @MainActor
    private func acceptActivity(_ activity: Activity) async {
      isLoadingActivities = true
      activityError = nil

      do {
        let response = try await transactionService.acceptMailboxTransaction(
          accessToken: session.accessToken,
          transactionId: activity.id
        ).value
        session.timeBalance = response.member?.timeBalance ?? session.timeBalance
        mailboxReloadCounter += 1
      } catch {
        activityError = error.isAuthenticationRequired ? nil : error.localizedDescription
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
        session.timeBalance = response.member?.timeBalance ?? session.timeBalance
        mailboxReloadCounter += 1
      } catch {
        activityError = error.isAuthenticationRequired ? nil : error.localizedDescription
      }

      isLoadingActivities = false
    }
}

#Preview {
    MailboxView(session: .constant(AuthSession()))
}
