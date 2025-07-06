//
//  CommunityView.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import SwiftUI
import SwiftData

struct CommunityView: View {
    let users: [User]
    let items: [Item]
    let modelContext: ModelContext
    
    @State private var showingRegistration = false
    @StateObject private var translationManager = TranslationManager.shared
    
    var body: some View {
        NavigationView {
            if users.isEmpty {
                // Empty state when no users are registered
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        
                        Text(translationManager.translate("no_users_registered"))
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text(translationManager.translate("welcome_message"))
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Button(action: {
                        showingRegistration = true
                    }) {
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
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .navigationTitle(translationManager.translate("community"))
            } else {
                // Show users list when users are registered
                List {
                    Section(translationManager.translate("registered_users")) {
                        ForEach(users, id: \.phone) { user in
                            NavigationLink {
                                UserDetailView(user: user)
                            } label: {
                                UserRowView(user: user)
                            }
                        }
                    }
                }
                .navigationTitle(translationManager.translate("community"))
            }
        }
        .sheet(isPresented: $showingRegistration) {
            RegistrationView()
        }
    }
}

struct UserRowView: View {
    let user: User
    @StateObject private var translationManager = TranslationManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.firstName.prefix(1) + user.lastName.prefix(1))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("@\(user.nickname)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Sports tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(user.sports.prefix(3), id: \.self) { sport in
                            Text(translationManager.translate(sport.lowercased()))
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                        
                        if user.sports.count > 3 {
                            Text("+\(user.sports.count - 3)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                )
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CommunityView(
        users: [
            User(phone: "+1 555-123-4567", firstName: "John", lastName: "Doe", nickname: "JohnnyD", sports: ["Soccer", "Basketball", "Tennis"], cityNeighborhood: "New York - Manhattan"),
            User(phone: "+1 555-987-6543", firstName: "Jane", lastName: "Smith", nickname: "JaneS", sports: ["Tennis", "Swimming"], cityNeighborhood: "Brooklyn - Williamsburg")
        ],
        items: [],
        modelContext: ModelContext(try! ModelContainer(for: User.self, Item.self))
    )
} 