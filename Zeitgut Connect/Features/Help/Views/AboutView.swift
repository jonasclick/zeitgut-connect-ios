//
//  AboutView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 01.06.2026.
//

import SwiftUI

struct AboutView: View {
  
  @Binding var isShowingFAQView: Bool
  
  private var currentYear: Int {
    Calendar.current.component(.year, from: .now)
  }
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      VStack (alignment: .leading) {
        Text("Über Zeitgut Connect")
          .font(.system(size: 28))
          .bold()
          .padding(.top)
          .padding(.bottom, 10)
        
        Text("Impressum")
          .font(.system(size: 24))
          .padding(.bottom, 5)
        
        ScrollView {
          VStack (alignment: .leading) {
            Text("Verantwortlich für den Inhalt (Autor)")
              .font(.headline)
            
            Text("""
Jonas Vetsch
Hubelhüsistrasse 12
3147 Mittelhäusern 
jonas@vetsch.com

© \(String(currentYear)) Jonas Vetsch - Alle Rechte vorbehalten.
""")
            .padding(.bottom)
            
            Text("Haftungsausschluss")
              .font(.headline)
            
            Text("""
Der Autor übernimmt keinerlei Gewähr hinsichtlich der inhaltlichen Richtigkeit, Genauigkeit, Aktualität, Zuverlässigkeit und  Vollständigkeit der Informationen.
""")
            .padding(.bottom, 8)
            
            Text("""
Haftungsansprüche gegen den Autor wegen Schäden materieller oder immaterieller Art, welche aus dem Zugriff oder der Nutzung bzw.  Nichtnutzung der veröffentlichten Informationen, durch Missbrauch der  Verbindung oder durch technische Störungen entstanden sind, werden ausgeschlossen.
""")
            .padding(.bottom)
            
            Text("Fehler entdeckt oder Verbesserungsvorschläge?")
              .font(.headline)
            Text("""
Wir legen grossen Wert auf die Qualität und Zuverlässigkeit unserer App und entwickeln sie kontinuierlich weiter. Solltest du auf Fehler stossen oder Anregungen und Verbesserungsvorschläge haben, freuen wir uns über deine Kontaktaufnahme.

Dein Feedback ist für uns ein wesentlicher Baustein, um die Anwendung gezielt zu optimieren und noch besser an deine Bedürfnisse anzupassen.
""")
            Spacer()
          }
          .padding(.bottom, 80)
        }
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
  }
}

#Preview {
  AboutView(isShowingFAQView: .constant(true))
    .padding()
    .applyAppBackground()
}
