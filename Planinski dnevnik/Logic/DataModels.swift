import Foundation

public let APIURL = SettingsHelper.getBackendUrl()

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
    let bio: String?
    let photo_path: String?
    let posts: [Post]?
}

class Post: Codable {
    let id: Int
    let name: String
    let description: String
    let user_id: Int
    let peak_id: Int?
    let photo_path: String
    let weather: String?
    let user: User?
}
