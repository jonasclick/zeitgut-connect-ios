//
//  FAQView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 01.06.2026.
//

import SwiftUI

struct FAQView: View {
  
  @Binding var isShowingFAQView: Bool
  @State private var isShowingAboutView: Bool = false
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      ScrollView {
        VStack (alignment: .leading) {
          Text("Häufig gestellte Fragen")
            .font(.system(size: 28))
            .bold()
            .padding(.top)
            .padding(.bottom, 10)
          
          Text("Wie kann ich Zeit erfassen, die ich geleistet oder erhalten habe?")
            .font(.headline)
          
          Text("Das Erfassen von Zeitgutschriften ist ganz einfach: Navigiere in der App unten zum Menütab «Zeit erfassen». Dort öffnet sich ein Formular, in dem du alle Details zum Einsatz (wie Dauer und Art der Hilfe) eintragen kannst.")
            .padding(.bottom)
          
          
          
          Text("Wer muss den Einsatz eintragen – die helfende oder die empfangende Person?")
            .font(.headline)
          
          Text("Das spielt keine Rolle. Beim Erfassen gibst du einfach an, ob du die Zeit «gegeben» oder «erhalten» hast. Wichtig ist nur, dass nur eine der beiden beteiligten Personen den Einsatz einträgt. Das System sorgt automatisch dafür, dass diese Zeiterfassung bei beiden Parteien verbucht wird, sobald die jeweils andere Partei sie in ihrem Briefkasten bestätigt hat.")
            .padding(.bottom)
          
          Text("Wozu dient der «Briefkasten» in der App?")
            .font(.headline)
          
          Text("Der Briefkasten ist deine persönliche Kontrollstation. Wenn jemand anderes einen Einsatz für dich / von dir erfasst hat, landet diese Anfrage zunächst dort. Du kannst die Details prüfen und die Anfrage mit einem Klick bestätigen oder ablehnen. Erst durch deine Bestätigung wird die Zeit für beide Konten definitiv verbucht.")
            .padding(.bottom)
          
          // SUBMIT BUTTON
          HStack {
            Spacer()
            Button {
              isShowingAboutView = true
            } label: {
              Text("Über Zeitgut Connect")
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
      
      Button {
        isShowingFAQView = false
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 15))
          .bold()
          .foregroundStyle(.softShell)
          .padding(11)
          .background(.delightfulOcean)
          .clipShape(Circle())
      }
      .accessibilityLabel("Hilfe und häufige Fragen")
      .zIndex(10)
      
    }
    .sheet(isPresented: $isShowingAboutView) {
      AboutView(isShowingFAQView: $isShowingFAQView)
        .padding()
        .applyAppBackground()
    }
    
  }
  
  private func handleAboutClick() {
    print("Click.")
  }
}

#Preview {
  FAQView(isShowingFAQView: .constant(true))
    .padding()
    .applyAppBackground()
  
}
