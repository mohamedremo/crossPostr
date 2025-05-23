import Foundation
import SwiftData

@Model
class Profile: Identifiable {
    var id: String
    var firstName: String
    var fullName: String
    var email: String
    var profileImageUrl: String?

    init(
        id: String = UUID().uuidString,
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

extension Profile {
    func toProfileDTO() -> ProfileDTO {
        ProfileDTO(
            id: self.id,
            firstName: self.firstName,
            fullName: self.fullName,
            email: self.email,
            profileImageUrl: self.profileImageUrl
        )
    }
}
