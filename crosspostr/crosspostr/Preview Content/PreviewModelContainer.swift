//
//  PreviewModelContainer.swift
//  crosspostr
//
//  Created by Mohamed Remo on 19.02.25.
//
import Foundation
import SwiftData

struct PreviewModelContainer {
    static var shared: ModelContainer = {
        do {
            let container = try ModelContainer(for: Media.self, configurations: .init(isStoredInMemoryOnly: true))
            return container
        } catch {
            fatalError("❌ Fehler beim Erstellen des Preview ModelContainers: \(error)")
        }
    }()
}
