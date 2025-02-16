import Foundation
import SwiftData

@Model
class Profile: Identifiable {
    var id: String
    var firstName: String
    var fullName: String
    var email: String
    var birthDate: Date?
    
    init(id: String = UUID().uuidString, firstName: String, fullName: String, email: String, birthDate: Date? = nil) {
        self.id = id
        self.firstName = firstName
        self.fullName = fullName
        self.email = email
        self.birthDate = birthDate
    }
}
