//
//  Draft.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//

import Foundation

/**
 The `Draft` struct represents a draft post in the `crosspostr` application.
 A draft is a post that the user has started but has not yet published.
 
 - Properties:
    - `id`: The unique identifier for the draft post. This is generated using `UUID`.
    - `title`: The title of the draft post. This can be edited by the user before the post is finalized and published.

 - Author: Mohamed Remo
 - Version: 1.0
 */

struct Draft: Identifiable, Codable {
    /// The unique identifier for the draft post.
    let id: UUID
    
    /// The title of the draft post.
    let title: String
    
    /**
     Initializes a new draft with a title.
     
     - Parameters:
        - title: The title of the draft post.
     
     - Returns: A new instance of `Draft`.
     */
    init(title: String) {
        self.id = UUID()  // Generate a unique identifier
        self.title = title
    }
}
