//
//  RemoteRepository.swift
//  crosspostr
//
//  Created by Mohamed Remo on 19.02.25.
//
import Foundation

@MainActor
class RemoteRepository {
    private let supabaseClient = BackendClient.shared.supabase
    private let authClient = BackendClient.shared.auth

    func getAllPostsRemote() async throws -> [PostDTO] {
        guard let currentUser = authClient.currentUser else {
            return []
        }
        let data: [PostDTO] = try await supabaseClient.from("posts")
            /// Selects the Table
            .select("*")/// Select all fields (equivalent to SQL "SELECT *")
            .eq("userId", value: currentUser.uid)
            .execute()
            /// Executes the Query and returns a response of the specified type in this case -> Draft.swift
            .value
        print("getAllPosts() ->", data)

        return data
    }

    func getPostRemote(id: Int) async throws -> PostDTO {
        let data: PostDTO = try await supabaseClient.from("posts")
            .select("*")
            .eq("id", value: id)
            .execute()
            .value

        return data
    }

    func insertPostRemote(newPost: PostDTO) async throws {
        try await supabaseClient.from("posts")
            .insert(newPost)
            .execute()
    }
}
