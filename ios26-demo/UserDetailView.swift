//
//  UserDetailView.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import SwiftUI

struct UserDetailView: View {
    let user: User
    @StateObject private var translationManager = TranslationManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(user.firstName.prefix(1) + user.lastName.prefix(1))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 8) {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("@\(user.nickname)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                // User Information Cards
                VStack(spacing: 16) {
                    InfoCard(title: translationManager.translate("phone_number"), value: user.phone, icon: "phone.fill")
                    InfoCard(title: translationManager.translate("location_info"), value: user.cityNeighborhood, icon: "location.fill")
                    
                    // Sports Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sportscourt.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text(translationManager.translate("sports_interests"))
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(user.sports, id: \.self) { sport in
                                Text(translationManager.translate(sport.lowercased()))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationTitle(translationManager.translate("registration"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    NavigationView {
        UserDetailView(user: User(
            phone: "+1 (555) 123-4567",
            firstName: "John",
            lastName: "Doe",
            nickname: "JohnnyD",
            sports: ["Soccer", "Basketball", "Tennis"],
            cityNeighborhood: "New York - Manhattan"
        ))
    }
} 