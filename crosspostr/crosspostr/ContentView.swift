//
//  ContentView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 20.01.25.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    let repo = Repository.shared
    @State var items: [Draft] = []
   
    var body: some View {
        VStack {
            ForEach(items) { item in
                Text(item.title)
            }
        }
        .task {
            do {
                items = try await repo.getAllDrafts() // "try?" bedeutet sollte ein Fehler passieren -> Ignorieren
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
}
