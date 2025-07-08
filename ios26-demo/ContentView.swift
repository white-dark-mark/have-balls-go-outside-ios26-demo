//
//  ContentView.swift
//  ios26-demo
//
//  Created by Marko Stankovic on 7/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @StateObject private var translationManager = TranslationManager.shared

    var body: some View {
        TabView {
            SportsMapView()
                .tabItem {
                    Label(translationManager.translate("map"), systemImage: "map.fill")
                }
            
            CommunityView(users: users, modelContext: modelContext)
                .tabItem {
                    Label(translationManager.translate("community"), systemImage: "person.3.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
