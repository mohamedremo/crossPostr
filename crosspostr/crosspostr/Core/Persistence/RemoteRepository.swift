//
//  RemoteRepository.swift
//  crossPostr
//
//  Description: Handles remote Supabase operations for posts, media and file storage.
//  Author: Mohamed Remo
//  Version: 1.0
//
import Foundation
import Supabase
import Storage
import FirebaseAuth

/// Provides async methods for interacting with Supabase tables (posts, media) and file storage (upload, download, delete).
@MainActor
class RemoteRepository {
    private let supabaseClient = BackendClient.shared.supabase
    private let authClient = BackendClient.shared.auth
    private let errorManager = ErrorManager.shared
    
    // MARK: - Storage-related Functions

    func uploadDataToSupabaseStorage(bucket: String, path: String, fileData: Data) async {
        let bucketReference = supabaseClient.storage.from(bucket)
        do {
            let response = try await bucketReference.upload(path, data: fileData, options: FileOptions(upsert: true)
            )
            print("Datei hochgeladen: \(response)")
        } catch {
            errorManager.setError(error)
        }
    }

    func downloadDataFromSupabaseStorage(bucket: String, path: String) async -> Data? {
        let bucketReference = supabaseClient.storage.from(bucket)
        do {
            let fileData = try await bucketReference.download(path: path)
            print("Datei heruntergeladen: \(path)")
            return fileData
        } catch {
            errorManager.setError(error)
        }
        return nil
    }

    func deleteDataFromSupabaseStorage(bucket: String, path: String) async {
        let bucketReference = supabaseClient.storage.from(bucket)
        do {
            _ = try await bucketReference.remove(paths: [path])
            print("Datei gelöscht: \(path)")
        } catch {
            errorManager.setError(error)
        }
    }
    // MARK: - Post-related Functions

    /**
     Fetches all posts from the "posts" table for the currently authenticated user.

     - Returns: An array of `PostDTO` objects.
     - Throws: An error if the request fails or user is not authenticated.
     */
    func getAllPostObjectsRemote() async -> [PostDTO] {
        do {
        guard let currentUser = authClient.currentUser else {
            errorManager.setError(AppError.noUser)
            throw AppError.noUser
        }
        
        
            let data: [PostDTO] = try await supabaseClient.from("posts")
                .select("*")
                .eq("userId", value: currentUser.uid )
                .execute()
                .value
            print("getAllPosts() ->", data)
            return data
        } catch {
            errorManager.setError(error)
        }
        print("getAllPosts() -> (empty array)")
        return []
    }

    func getPostObjectsRemote(id: UUID) async -> PostDTO? {
        do {
            let data: PostDTO = try await supabaseClient.from("posts")
                .select("*")
                .eq("id", value: id)
                .execute()
                .value
            return data
        } catch {
            errorManager.setError(error)
        }
        return nil
    }

    func insertPostObjectRemote(newPost: PostDTO) async {
        do {
            try await supabaseClient.from("posts")
                .insert(newPost)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }
    
    func updatePostObjectRemote(postId: UUID, updatedPost: PostDTO) async {
        do {
            try await supabaseClient.from("posts")
                .update(updatedPost)
                .eq("id", value: postId)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }

    func deletePostObjectRemote(postId: UUID) async {
        do {
            try await supabaseClient.from("posts")
                .delete()
                .eq("id", value: postId)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }

    // MARK: - Media-Object-related Functions

    func getAllMediaObjectsRemote() async -> [MediaDTO] {
        do {
            guard let currentUser = authClient.currentUser else {
                throw AppError.noUser
            }

            let data: [MediaDTO] = try await supabaseClient.from("media")
                .select("*")
                .eq("userId", value: currentUser.uid)
                .execute()
                .value

            print("getAllMedia() ->", data)
            return data
        } catch {
            errorManager.setError(error)
        }
        return []
    }

    func getMediaObjectRemote(id: UUID) async -> MediaDTO? {
        do {
            let data: MediaDTO = try await supabaseClient.from("media")
                .select("*")
                .eq("id", value: id)
                .execute()
                .value
            return data
        } catch {
            errorManager.setError(error)
        }
        return nil
    }

    func insertMediaObjectRemote(newMedia: MediaDTO) async  {
        do {
            try await supabaseClient.from("media")
                .insert(newMedia)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }

    func updateMediaObjectRemote(mediaId: UUID, updatedMedia: MediaDTO) async {
        do {
            try await supabaseClient.from("media")
                .update(updatedMedia)
                .eq("id", value: mediaId)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }

    func deleteMediaObjectRemote(mediaId: UUID) async {
        do {
            try await supabaseClient.from("media")
                .delete()
                .eq("id", value: mediaId)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }
    
    //MARK: - Profile-Object-related Functions
    
    func getProfileObjectRemote() async -> ProfileDTO? {
         do {
            guard let currentUser = authClient.currentUser else {
                errorManager.setError(AppError.noUser)
                throw AppError.noUser
            }
            
            let data: ProfileDTO = try await supabaseClient.from("profiles")
                .select("*")
                .eq("id", value: currentUser.uid)
                .single()
                .execute()
                .value
            
            return data
         } catch {
             errorManager.setError(error)
         }
        return nil
    }
    
    func insertProfileObjectRemote(newProfile: ProfileDTO) async {
        do {
            try await supabaseClient.from("profiles")
                .insert(newProfile)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }
    
    func updateProfileObjectRemote(profileId: String, updatedProfile: ProfileDTO) async {
        do {
            try await supabaseClient.from("profiles")
                .update(updatedProfile)
                .eq("id", value: profileId)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }
    
    func deleteProfileObjectRemote(profileId: UUID) async {
        do {
            try await supabaseClient.from("profiles")
                .delete()
                .eq("id", value: profileId)
                .execute()
        } catch {
            errorManager.setError(error)
        }
    }
}
