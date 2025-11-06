import Foundation

public let APIURL = SettingsHelper.getApiUrl()

struct Token: Codable {
    let accessToken: String
    let refreshToken: String
}

struct UserSession: Codable {
    let token: Token
    let user: User
}

class User: Codable {
    let id_user: Int
    let name: String
    let email: String?
    let password: String
    let registration_date: String
    //let bio: String?
    //let photo_uri: String?
}
