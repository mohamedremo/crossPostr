//
//  ProfileDTO.swift
//  crosspostr
//
//  Created by Mohamed Remo on 23.03.25.
//
import Foundation

struct ProfileDTO: Codable, Sendable { //
    var id: String
    var firstName: String
    var fullName: String
    var email: String
    var profileImageUrl: String?

    init(
        id: String,
        firstName: String,
        fullName: String,
        email: String,
        profileImageUrl: String?
    ) {
        self.id = id
        self.firstName = firstName
        self.fullName = fullName
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
}
extension ProfileDTO {
    func toProfile() -> Profile {
        return Profile(
            id: self.id,
            firstName: self.firstName,
            fullName: self.fullName,
            email: self.email,
            profileImageUrl: self.profileImageUrl
        )
    }
}
