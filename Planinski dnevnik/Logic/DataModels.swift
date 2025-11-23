import Foundation

public let APIURL = "http://127.0.0.1:3000"//SettingsHelper.getApiUrl()

struct Token: Codable {
    let access_token: String
    let refresh_token: String
}

struct UserSession: Codable {
    let token: Token
    let user: User
}

class User: Codable {
    let id: Int
    let name: String
    let email: String?
    //let registration_date: String
    //let bio: String?
    //let photo_uri: String?
}

class Post: Codable {
    let id: Int
    let title: String
    let description: String
    let user: String
    let photoUrl: String
}
