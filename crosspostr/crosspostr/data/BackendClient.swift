//
//  SupabaseClient.swift
//  crosspostr
//
//  Created by Mohamed Remo on 23.01.25.
//

import Foundation
import Supabase

struct BackendClient {
    static let shared: BackendClient = BackendClient()

    let supabase = SupabaseClient(
        supabaseURL: URL(string: apiHost.supabase.rawValue)!,
        supabaseKey: apiKey.supabase.rawValue)

}

class Repository: ObservableObject {
    static let shared: Repository = Repository()
    
    private let supabaseClient = BackendClient.shared.supabase
    
    func getAllDrafts() async throws -> [Draft] {
        let data: [Draft] = try await supabaseClient.from("drafts") // Wählt die tabelle
            .select("*") // Wählt das Feld. In diesem Falle "title" Wenn select leer dann ganze Tabelle
            .execute()
            .value
        
        return data
    }
}


struct Draft: Identifiable, Codable {
    let id: UUID
    let title: String
}
