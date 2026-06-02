//
//  LogTimeConfirmationView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 02.06.2026.
//

import SwiftUI

struct LogTimeConfirmationView: View {
  
  @Binding var isShowingSuccessView: Bool
  
  @Binding var selectedDate: Date
  @Binding var isReceived: Bool
  @Binding var selectedCategory: String
  @Binding var selectedPerson: String
  @Binding var durationHours: Int
  @Binding var durationMinutes: Int
  
  var body: some View {
    ScrollView {
      VStack (alignment: .leading) {
        Text("Zeit erfolgreich erfasst")
          .font(.system(size: 28))
          .bold()
          .padding(.top)
          .padding(.bottom, 32)
        
        // GIVEN / RECEIVED
        HStack {
          Text("Ich habe Zeit")
            .font(.system(size: 20))
            .bold()
          Text(isReceived ? "erhalten" : "gegeben")
            .font(.system(size: 20))
            .bold()
            .foregroundStyle(Color.mutedSuccess)
        }
        .padding(.bottom)
        
        // PERSDON
        HStack {
          Text(isReceived ? "von" : "für")
            .font(.system(size: 20))
            .bold()
          Text(selectedPerson)
            .font(.system(size: 20))
            .bold()
            .foregroundStyle(Color.mutedSuccess)
        }
        .padding(.bottom)

        // DATE
        HStack {
          Text("am")
            .font(.system(size: 20))
            .bold()
          Text(selectedDate, format: .dateTime.day(.twoDigits).month(.twoDigits).year())
            .font(.system(size: 20))
            .bold()
            .foregroundStyle(Color.mutedSuccess)
        }
        .padding(.bottom)

        // Kategorie
        HStack {
          Text("Kategorie")
            .font(.system(size: 20))
            .bold()
          Text(selectedCategory)
            .font(.system(size: 20))
            .bold()
            .foregroundStyle(Color.mutedSuccess)
        }
        .padding(.bottom)

        // DURATION
        HStack {
          Text("Dauer")
            .font(.system(size: 20))
            .bold()
          Text("\(durationHours) Stunden")
            .font(.system(size: 20))
            .bold()
            .foregroundStyle(Color.mutedSuccess)
          Text("\(durationMinutes) Minuten")
            .font(.system(size: 20))
            .bold()
            .foregroundStyle(Color.mutedSuccess)
        }
        .padding(.bottom, 32)
        
        // CLOSE SHEET
        HStack {
          Spacer()
          Button {
            isShowingSuccessView = false
          } label: {
            Text("Fertig")
              .foregroundStyle(Color.delightfulOcean)
              .bold()
              .padding(.vertical, 12)
              .padding(.horizontal, 35)
              .foregroundColor(.white)
              .background(Color.silentMint)
              .cornerRadius(15)
          }
          Spacer()
        }
      }
      .padding(.bottom, 80)
    }
    .scrollIndicators(.hidden)
  }
}


#Preview {
  LogTimeConfirmationView(isShowingSuccessView: .constant(true), selectedDate: .constant(Date()), isReceived: .constant(true), selectedCategory: .constant("Gartenarbeit"), selectedPerson: .constant("Margrit Buri"), durationHours: .constant(2), durationMinutes: .constant(15))
    .padding()
    .applyAppBackground()
}
