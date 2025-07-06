//
//  RegistrationView.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import SwiftUI
import SwiftData

struct RegistrationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var phone = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var nickname = ""
    @State private var selectedSports: Set<String> = []
    @State private var cityNeighborhood = ""
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @StateObject private var translationManager = TranslationManager.shared
    
    let availableSports = [
        SportItem(name: "Soccer", icon: "⚽"),
        SportItem(name: "Basketball", icon: "🏀"),
        SportItem(name: "Tennis", icon: "🎾"),
        SportItem(name: "Baseball", icon: "⚾"),
        SportItem(name: "American Football", icon: "🏈"),
        SportItem(name: "Volleyball", icon: "🏐"),
        SportItem(name: "Swimming", icon: "🏊"),
        SportItem(name: "Running", icon: "🏃"),
        SportItem(name: "Cycling", icon: "🚴"),
        SportItem(name: "Boxing", icon: "🥊"),
        SportItem(name: "Martial Arts", icon: "🥋"),
        SportItem(name: "Golf", icon: "⛳"),
        SportItem(name: "Ice Hockey", icon: "🏒"),
        SportItem(name: "Skiing", icon: "⛷️"),
        SportItem(name: "Snowboarding", icon: "🏂"),
        SportItem(name: "Surfing", icon: "🏄"),
        SportItem(name: "Skateboarding", icon: "🛹"),
        SportItem(name: "Wrestling", icon: "🤼"),
        SportItem(name: "Weightlifting", icon: "🏋️"),
        SportItem(name: "Gymnastics", icon: "🤸")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(translationManager.translate("registration"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(translationManager.translate("welcome_message"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Form Content
                    VStack(spacing: 20) {
                        // Personal Information Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(translationManager.translate("contact_info"))
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            CustomTextField(
                                title: translationManager.translate("phone_number"),
                                text: $phone,
                                placeholder: "+381 (60) 123-4567",
                                keyboardType: .phonePad
                            )
                            
                            HStack(spacing: 12) {
                                CustomTextField(
                                    title: translationManager.translate("first_name"),
                                    text: $firstName,
                                    placeholder: "Marko"
                                )
                                
                                CustomTextField(
                                    title: translationManager.translate("last_name"),
                                    text: $lastName,
                                    placeholder: "Stanković"
                                )
                            }
                            
                            CustomTextField(
                                title: translationManager.translate("nickname"),
                                text: $nickname,
                                placeholder: "MarkoS"
                            )
                        }
                        
                        Divider()
                        
                        // Sports Selection Section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(translationManager.translate("sports_you_play"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(translationManager.translate("select_sports_hint"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(availableSports, id: \.name) { sport in
                                    SportSelectionCard(
                                        sport: sport,
                                        isSelected: selectedSports.contains(sport.name)
                                    ) {
                                        if selectedSports.contains(sport.name) {
                                            selectedSports.remove(sport.name)
                                        } else {
                                            selectedSports.insert(sport.name)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Location Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text(translationManager.translate("location_info"))
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            CustomTextField(
                                title: translationManager.translate("city_neighborhood"),
                                text: $cityNeighborhood,
                                placeholder: "Beograd - Novi Beograd"
                            )
                        }
                        
                        // Register Button
                        Button(action: registerUser) {
                            Text(translationManager.translate("register_button"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(translationManager.translate("cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .alert(translationManager.translate("registration"), isPresented: $showingAlert) {
            Button(translationManager.translate("done")) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func registerUser() {
        // Validation
        guard !phone.isEmpty else {
            showAlert(message: translationManager.translate("please_fill_required_fields"))
            return
        }
        
        guard !firstName.isEmpty else {
            showAlert(message: translationManager.translate("please_fill_required_fields"))
            return
        }
        
        guard !lastName.isEmpty else {
            showAlert(message: translationManager.translate("please_fill_required_fields"))
            return
        }
        
        guard !nickname.isEmpty else {
            showAlert(message: translationManager.translate("please_fill_required_fields"))
            return
        }
        
        guard !selectedSports.isEmpty else {
            showAlert(message: translationManager.translate("select_at_least_one_sport"))
            return
        }
        
        guard !cityNeighborhood.isEmpty else {
            showAlert(message: translationManager.translate("please_fill_required_fields"))
            return
        }
        
        // Create user
        let newUser = User(
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            nickname: nickname,
            sports: Array(selectedSports),
            cityNeighborhood: cityNeighborhood
        )
        
        modelContext.insert(newUser)
        
        showAlert(message: translationManager.translate("registration_successful"))
        
        // Reset form
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}

struct SportItem {
    let name: String
    let icon: String
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(keyboardType)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

struct SportSelectionCard: View {
    let sport: SportItem
    let isSelected: Bool
    let action: () -> Void
    @StateObject private var translationManager = TranslationManager.shared
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(sport.icon)
                    .font(.title2)
                
                Text(translationManager.translate(sport.name.lowercased()))
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                          LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing) : 
                          LinearGradient(gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RegistrationView()
        .modelContainer(for: User.self, inMemory: true)
} 