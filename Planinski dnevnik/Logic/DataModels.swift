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
    let user: User?
}
