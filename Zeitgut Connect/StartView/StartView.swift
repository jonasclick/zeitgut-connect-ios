//
//  StartView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 30.05.2026.
//

import SwiftUI

struct StartView: View {
    var body: some View {
      VStack (alignment: .leading){
        
        Text("Zeitgut Connect")
          .bold()
        
        HStack {
          Text("Mein Stundensaldo")
          Spacer()
          Text("5.4h")
            .bold()
            .frame(width: 80, height: 80)
            .background(
              Capsule()
                .fill(Color.mutedSuccess)
              )
        }
      }
    }
}

#Preview {
    StartView()
}
