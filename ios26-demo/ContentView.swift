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
    @Query private var items: [Item]
    @Query private var users: [User]
    @StateObject private var translationManager = TranslationManager.shared

    var body: some View {
        TabView {
            SportsMapView()
                .tabItem {
                    Label(translationManager.translate("map"), systemImage: "map.fill")
                }
            
            CommunityView(users: users, items: items, modelContext: modelContext)
                .tabItem {
                    Label(translationManager.translate("community"), systemImage: "person.3.fill")
                }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
