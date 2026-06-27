//
//  AboutView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 01.06.2026.
//

import SwiftUI

struct AboutView: View {
  
  @Binding var isShowingFAQView: Bool
  
  var body: some View {
    ZStack(alignment: .topTrailing) {
      ScrollView {
        VStack (alignment: .leading) {
          Text("Über Zeitgut Connect")
            .font(.system(size: 28))
            .bold()
            .padding(.top)
            .padding(.bottom, 10)
          
          Text("Herstellerangaben")
            .font(.headline)
          
          Text("""
Zeitgut Connect wird entwickelt von Jonas Vetsch
Hubelhüsistrasse 12
3147 Mittelhäusern
Im Rahmen eines Lernprojekts an der gibb Berufsfachschule Bern. © 2026
""")
          .padding(.bottom)
          
          
          
          Text("Anbieter")
            .font(.headline)
          
          Text("Zeitgut Connect wird angeboten vom Verein Zeitgut, 3147 Mittelhäusern.")
            .padding(.bottom)
          
          Text("Verantwortlich für den Inhalt")
            .font(.headline)
          
          Text("""
Jonas Vetsch
Hubelhüsistrasse 12
3147 Mittelhäusern 
jve161514@stud.gibb.ch
""")
          .padding(.bottom)
          
          Text("Haftungsausschluss")
            .font(.headline)
          
          Text("""
Der Autor übernimmt keinerlei Gewähr hinsichtlich der inhaltlichen Richtigkeit, Genauigkeit, Aktualität, Zuverlässigkeit und  Vollständigkeit der Informationen.
""")
          .padding(.bottom, 8)
          
          Text("""
Haftungsansprüche gegen den Autor wegen Schäden materieller  oder immaterieller Art, welche aus dem Zugriff oder der Nutzung bzw.  Nichtnutzung der veröffentlichten Informationen, durch Missbrauch der  Verbindung oder durch technische Störungen entstanden sind, werden ausgeschlossen.
""")
          .padding(.bottom)
          
          Spacer()
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
  }
}

#Preview {
  AboutView(isShowingFAQView: .constant(true))
    .padding()
    .applyAppBackground()
}
