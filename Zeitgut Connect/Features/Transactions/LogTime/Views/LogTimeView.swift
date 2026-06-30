//
//  LogTimeView.swift
//  Zeitgut Connect
//
//  Created by Jonas Vetsch on 31.05.2026.
//

import SwiftUI

struct LogTimeView: View {
  let session: AuthSession

  @State private var selectedDate = Date()
  @State private var isReceived = true
  @State private var selectedCategoryId = ""
  @State private var selectedPersonId = ""
  @State private var durationHours: Int = 0
  @State private var durationMinutes: Int = 0

  @State private var showErrors = false
  @State private var isShowingSuccessView = false
  @State private var isLoadingOptions = false
  @State private var isSubmitting = false
  @State private var optionsError: String?
  @State private var submitError: String?
  @State private var members: [MemberOption] = []
  @State private var categories: [TimeCategoryOption] = []
  @State private var confirmationPersonName = ""
  @State private var confirmationCategoryLabel = ""

  private let transactionService = TransactionService()

  // MARK: Validation Logic
  private var isPersonValid: Bool { !selectedPersonId.isEmpty }
  private var isCategoryValid: Bool { !selectedCategoryId.isEmpty }
  private var isDurationValid: Bool { durationHours > 0 || durationMinutes > 0 }

  private var isFormValid: Bool {
    isPersonValid && isCategoryValid && isDurationValid
  }

  private var totalDurationMinutes: Int {
    durationHours * 60 + durationMinutes
  }

  private var selectedPersonName: String {
    members.first { $0.id == selectedPersonId }?.displayName ?? ""
  }

  private var selectedCategoryLabel: String {
    categories.first { $0.id == selectedCategoryId }?.label ?? ""
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
            
            Picker("Bitte wählen", selection: $selectedPersonId) {
              Text("Bitte Person auswählen").tag("")
              ForEach(members) { person in
                Text(person.displayName).tag(person.id)
              }
            }
            .tint(Color.mutedSuccess)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .disabled(isLoadingOptions || members.isEmpty)
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
            
            Picker("Bitte wählen", selection: $selectedCategoryId) {
              Text("Bitte Kategorie auswählen").tag("")
              ForEach(categories) { category in
                Text(category.label).tag(category.id)
              }
            }
            .tint(Color.mutedSuccess)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .disabled(isLoadingOptions || categories.isEmpty)
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

        if isLoadingOptions {
          ProgressView("Auswahl wird geladen...")
            .frame(maxWidth: .infinity, alignment: .center)
        } else if let optionsError {
          Text(optionsError)
            .font(.footnote)
            .foregroundColor(.softError)
            .frame(maxWidth: .infinity, alignment: .center)
        }

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
        .disabled(isSubmitting || isLoadingOptions)
        errorFooter(isValid: isFormValid, message: "Das Formular enthält ungültige Felder. Bitte prüfen.")
        if isSubmitting {
          ProgressView()
            .padding(.top, 4)
        } else if let submitError {
          Text(submitError)
            .font(.footnote)
            .foregroundColor(.softError)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
      }
      .padding(.bottom, 80)
    }
    .padding()
    .task(id: session.accessToken) {
      await loadFormOptions()
    }
    .sheet(isPresented: $isShowingSuccessView, onDismiss: {
      clearFormData()
    }) {
      LogTimeConfirmationView(isShowingSuccessView: $isShowingSuccessView, selectedDate: $selectedDate, isReceived: $isReceived, selectedCategory: .constant(confirmationCategoryLabel), selectedPerson: .constant(confirmationPersonName), durationHours: $durationHours, durationMinutes: $durationMinutes)
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
    Task {
      await submitForm()
    }
  }

  private func submitForm() async {
    submitError = nil

    guard isFormValid else {
      withAnimation {
        showErrors = true
        isShowingSuccessView = false
      }
      return
    }

    guard session.accessToken.isEmpty == false else {
      submitError = "Bitte melde dich erneut an."
      return
    }

    isSubmitting = true
    showErrors = false

    do {
      _ = try await transactionService.createTransaction(
        accessToken: session.accessToken,
        request: CreateTransactionRequest(
          date: Self.backendDateFormatter.string(from: selectedDate),
          direction: isReceived ? "received" : "given",
          partnerId: selectedPersonId,
          categoryId: selectedCategoryId,
          durationMinutes: totalDurationMinutes
        )
      )

      confirmationPersonName = selectedPersonName
      confirmationCategoryLabel = selectedCategoryLabel
      isShowingSuccessView = true
    } catch {
      submitError = error.localizedDescription
    }

    isSubmitting = false
  }
  
  private func clearFormData() {
    // Reset State for additional views
    showErrors = false
    isShowingSuccessView = false
    
    // RESET FORM DATA
    selectedDate = Date()
    isReceived = true
    selectedCategoryId = ""
    selectedPersonId = ""
    durationHours = 0
    durationMinutes = 0
    submitError = nil
    confirmationPersonName = ""
    confirmationCategoryLabel = ""
  }

  private func loadFormOptions() async {
    guard session.accessToken.isEmpty == false else {
      members = []
      categories = []
      return
    }

    isLoadingOptions = true
    optionsError = nil

    do {
      async let membersResponse = transactionService.fetchMembers(accessToken: session.accessToken).value
      async let categoriesResponse = transactionService.fetchTimeCategories(accessToken: session.accessToken).value
      let loadedMembersResponse = try await membersResponse
      let loadedCategoriesResponse = try await categoriesResponse

      members = loadedMembersResponse.members
        .filter { $0.id != (loadedMembersResponse.currentMemberId ?? session.userId) }
      categories = loadedCategoriesResponse.categories

      if members.isEmpty || categories.isEmpty {
        optionsError = "Es stehen noch nicht alle Auswahldaten bereit."
      }
    } catch {
      optionsError = error.localizedDescription
    }

    isLoadingOptions = false
  }

  private static let backendDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
}

#Preview {
    LogTimeView(session: AuthSession())
    .applyAppBackground()
    .ignoresSafeArea()
    .padding(.top, 50)
}
