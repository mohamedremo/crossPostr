import Foundation
import SwiftData

@Model
class Profile: Identifiable {
    var id: String
    var firstName: String
    var fullName: String
    var email: String
    var birthDate: Date?
    var profileImageUrl: String?
    
    init(id: String = UUID().uuidString, firstName: String, fullName: String, email: String, birthDate: Date?, profileImageUrl: String?) {
        self.id = id
        self.firstName = firstName
        self.fullName = fullName
        self.email = email
        self.birthDate = birthDate
        self.profileImageUrl = profileImageUrl
    }
    
}
