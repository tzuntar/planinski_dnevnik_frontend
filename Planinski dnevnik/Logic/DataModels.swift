import Foundation

public let APIURL = "http://192.168.0.25:3000"//SettingsHelper.getApiUrl()

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
    //let registration_date: String
    //let photo_uri: String?
    
}

class Post: Codable {
    let id: Int
    let title: String
    let description: String
    let user: String
    //let photoUrl: String
    let nadmorska_visina: Int?
}
