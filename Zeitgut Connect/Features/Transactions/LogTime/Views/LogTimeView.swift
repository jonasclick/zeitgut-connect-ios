//
//  LogTimeView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import SwiftUI

struct LogTimeView: View {
  @State private var selectedDate = Date()
  @State private var isReceived = true
  @State private var selectedCategory = ""
  @State private var selectedPerson: String = ""
  @State private var durationHours: Int = 0
  @State private var durationMinutes: Int = 0
  
  @State private var showErrors = false
  @State private var isShowingSuccessView = false

  let categories = ["Gartenarbeit", "Mit dem Hund spazieren", "Einkaufshilfe", "Briefversand abpacken", "Handwerkliche Arbeiten", "Klavierunterricht", "Deutsch lernen (Sprachtandem)"]
  
  let people = [
    "Ruben Lüti",
    "Marco Tanner",
    "Margrit Buri",
    "Regula Peters",
    "Margrit Burgi",
    "Jakob Rieder",
    "Lina Pfister",
    "Lydia Berberat"]
  
  // MARK: Validation Logic
  private var isPersonValid: Bool { !selectedPerson.isEmpty }
  private var isCategoryValid: Bool { !selectedCategory.isEmpty }
  private var isDurationValid: Bool { durationHours > 0 || durationMinutes > 0 }
  
  private var isFormValid: Bool {
    isPersonValid && isCategoryValid && isDurationValid
  }
  
  var body: some View {
    ZStack {
      VStack (alignment: .leading) {
        Text("Zeit erfassen")
          .font(.system(size: 28))
          .bold()
          .padding(.bottom, 10)
        
        // DATE
        HStack {
          Text("Datum auswählen")
            .font(.system(size: 20))
            .bold()
          
          DatePicker(
            "",
            selection: $selectedDate,
            displayedComponents: [.date]
          )
          .datePickerStyle(.compact)
          .tint(.mutedSuccess)
          .padding()
        }
        .frame(height: 100)
        
        // GIVEN / RECEIVED
        VStack (alignment: .leading) {
          Text("Ich habe Zeit...")
            .font(.system(size: 20))
            .bold()
          
          Picker("", selection: $isReceived) {
            Text("erhalten.").tag(true)
              .font(.system(size: 28))
              .bold()
            Text("gegeben.").tag(false)
              .font(.system(size: 28))
              .bold()
          }
          .pickerStyle(.segmented)
          .padding(.bottom)
        }
        .frame(height: 100)
        
        // PERSON
        VStack {
          HStack {
            Text("Person")
              .font(.system(size: 20))
              .bold()
            
            // 3. Der Picker selbst
            Picker("Bitte wählen", selection: $selectedPerson) {
              Text("Bitte Person auswählen").tag("")
              ForEach(people, id: \.self) { person in
                Text(person)
              }
            }
            .tint(Color.mutedSuccess)
            .frame(maxWidth: .infinity, alignment: .trailing)
          }
          errorFooter(isValid: isPersonValid, message: "Bitte wähle eine Person aus.")
        }
        .frame(height: 70, alignment: .top)
        
        // CATEGORY
        VStack {
          HStack {
            Text("Kategorie")
              .font(.system(size: 20))
              .bold()
            
            // 3. Der Picker selbst
            Picker("Bitte wählen", selection: $selectedCategory) {
              Text("Bitte Kategorie auswählen").tag("")
              ForEach(categories, id: \.self) { person in
                Text(person)
              }
            }
            .tint(Color.mutedSuccess)
            .frame(maxWidth: .infinity, alignment: .trailing)
          }
          errorFooter(isValid: isCategoryValid, message: "Bitte wähle eine Kategorie aus.")
        }
        .frame(height: 70, alignment: .top)
        .padding(.bottom, -40)
        
        // TIME
        VStack {
          HStack(spacing: 0) {
            Text("Dauer")
              .font(.system(size: 20))
              .bold()
            Spacer()
            
            // Stunden-Picker
            Picker("Stunden", selection: $durationHours) {
              ForEach(0..<24) { hour in
                Text("\(hour) h").tag(hour)
              }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            
            // Minuten-Picker
            Picker("Minuten", selection: $durationMinutes) {
              ForEach(0..<60) { minute in
                Text("\(minute) min").tag(minute)
              }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            
            Spacer()
          }
          errorFooter(isValid: isDurationValid, message: "Die Dauer darf nicht 0 sein.")
        }
        .frame(height: 160, alignment: .top)

        // Push Content up (top align)
        Spacer()
          
      }
      
      // SUBMIT BUTTON
      VStack {
        // Push Button to Bottom
        Spacer()
        Button(action: submitForm) {
          Text("Zeiterfassung absenden")
            .foregroundStyle(Color.delightfulOcean)
            .bold()
            .padding(.vertical, 12)
            .padding(.horizontal, 35)
            .foregroundColor(.white)
            .background(Color.silentMint)
            .cornerRadius(15)
        }
        errorFooter(isValid: isFormValid, message: "Das Formular enthält ungültige Felder. Bitte prüfen.")
      }
      .padding(.bottom, 80)
    }
    .padding()
    .sheet(isPresented: $isShowingSuccessView, onDismiss: {
      clearFormData()
    }) {
      LogTimeConfirmationView(isShowingSuccessView: $isShowingSuccessView, selectedDate: $selectedDate, isReceived: $isReceived, selectedCategory: $selectedCategory, selectedPerson: $selectedPerson, durationHours: $durationHours, durationMinutes: $durationMinutes)
        .padding()
        .applyAppBackground()
    }
  }
  
  @ViewBuilder
  private func errorFooter(isValid: Bool, message: String) -> some View {
        if showErrors && !isValid {
          Text(message)
            .foregroundColor(.softError)
            .transition(.opacity)
    }
  }
  
  private func submitForm() {
    if isFormValid {
      showErrors = false
      
      // Show Success
      isShowingSuccessView = true

      // CONSOLE LOG
      print("Formular erfolgreich abgesendet!")
      
    } else {
      withAnimation {
        showErrors = true
        isShowingSuccessView = false
      }
    }
  }
  
  private func clearFormData() {
    // Reset State for additional views
    showErrors = false
    isShowingSuccessView = false
    
    // RESET FORM DATA
    selectedDate = Date()
    isReceived = true
    selectedCategory = ""
    selectedPerson = ""
    durationHours = 0
    durationMinutes = 0
  }
}

#Preview {
    LogTimeView()
    .applyAppBackground()
    .ignoresSafeArea()
    .padding(.top, 50)
}
