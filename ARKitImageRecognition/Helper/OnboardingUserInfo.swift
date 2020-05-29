import Foundation

struct OnboardingUserInfo {
    var firstName : String? = ""
    var lastName : String? = ""
    var email : String?
    var birthdate : Date? = Date()
    var profilePictureURL : URL? = nil
    
    init(email:String) { self.email = email }
    
    init(firstName: String, lastName : String, email: String, birthdate: Date, profilePictureURL: URL) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.birthdate = birthdate
        self.profilePictureURL = profilePictureURL
    }
    
}
