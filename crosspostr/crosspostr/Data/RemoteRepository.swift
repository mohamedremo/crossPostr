//
//  RemoteRepository.swift
//  crosspostr
//
//  Created by Mohamed Remo on 19.02.25.
//
import Foundation
import Supabase
import Storage

@MainActor
class RemoteRepository {
    private let supabaseClient = BackendClient.shared.supabase
    private let authClient = BackendClient.shared.auth
    
    // MARK: - Storage-related Functions
    func uploadFile(path: String, fileData: Data) async {
        let bucketReference = supabaseClient.storage.from("media-files")
        do {
            let response = try await bucketReference.upload(path, data: fileData, options: FileOptions(upsert: true))
            print("Upload erfolgreich: \(response)")
        } catch {
            print("Upload-Fehler: \(error.localizedDescription)")
        }
    }

    func downloadFile(bucket: String, path: String) async throws -> Data {
        let bucketReference = supabaseClient.storage.from(bucket)
        do {
            let fileData = try await bucketReference.download(path: path)
            print("Datei heruntergeladen: \(path)")
            return fileData
        } catch {
            throw error
        }
    }

    func deleteFile(bucket: String, path: String) async throws {
        let bucketReference = supabaseClient.storage.from(bucket)
        do {
            let toDelete = try await bucketReference.remove(paths: [path])
            print("Datei gelöscht: \(path) -> \(toDelete)")
        } catch {
            throw error
        }
    }
    
    // MARK: - Post-related Functions
    func getAllPostsRemote() async throws -> [PostDTO] {
        guard let currentUser = authClient.currentUser else {
            print("No User logged in")
            return []
        }
        let data: [PostDTO] = try await supabaseClient.from("posts")
            .select("*")
            .eq("userId", value: currentUser.uid)
            .execute()
            .value
        print("getAllPosts() ->", data)
        return data
    }

    func getPostRemote(id: UUID) async throws -> PostDTO {
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

    func updatePostRemote(postId: UUID, updatedPost: PostDTO) async throws {
        try await supabaseClient.from("posts")
            .update(updatedPost)
            .eq("id", value: postId)
            .execute()
    }

    func deletePostRemote(postId: UUID) async throws {
        try await supabaseClient.from("posts")
            .delete()
            .eq("id", value: postId)
            .execute()
    }

    // MARK: - Media-related Functions
    func getAllMediaRemote() async throws -> [MediaDTO] {
        guard let currentUser = authClient.currentUser else {
            print("No User logged in")
            return []
        }
        let data: [MediaDTO] = try await supabaseClient.from("media")
            .select("*")
            .eq("userId", value: currentUser.uid)
            .execute()
            .value
        print("getAllMedia() ->", data)
        return data
    }

    func getMediaRemote(id: UUID) async throws -> MediaDTO {
        let data: MediaDTO = try await supabaseClient.from("media")
            .select("*")
            .eq("id", value: id)
            .execute()
            .value
        return data
    }

    func insertMediaRemote(newMedia: MediaDTO) async throws {
        try await supabaseClient.from("media")
            .insert(newMedia)
            .execute()
    }

    func updateMediaRemote(mediaId: UUID, updatedMedia: MediaDTO) async throws {
        try await supabaseClient.from("media")
            .update(updatedMedia)
            .eq("id", value: mediaId)
            .execute()
    }

    func deleteMediaRemote(mediaId: UUID) async throws {
        try await supabaseClient.from("media")
            .delete()
            .eq("id", value: mediaId)
            .execute()
    }
}
