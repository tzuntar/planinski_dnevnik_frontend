//
//  UserLogic.swift
//  Planinski dnevnik
//
//  Created by Mark Horvat on 24. 11. 25.
//

import Foundation
import Alamofire
import UIKit

protocol UserProfileDelegate {
    func didLoadUserData(_ user: User)
    func didLoadingFailWithError(_ error: Error)
    func didUpdateUserData()
    func didChangePasswordSuccessfully()
    func didUpdateAvatar(newUrl: String)
}

struct AvatarResponse: Decodable {
    let message: String
    let photo_uri: String
}

enum UserProfileError: Error,CustomStringConvertible {
    case noData
    case unauthorized
    case missingAuthHeaders
    case unexpected(code: Int)
    
    var description: String {
        switch self {
        case .noData:
            return "Ni podatkov."
        case .unauthorized:
            return "Nimate dostopa."
        case .missingAuthHeaders:
            return "Avtorizacija ni uspela."
        case .unexpected:
            return "Prišlo je do napake."
        }
    }
}

class UserLogic {
    let delegate: UserProfileDelegate

    init(delegatingActionsTo delegate: UserProfileDelegate) {
        self.delegate = delegate
    }
    
    func retrieveData(for userId: Int) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else {
            delegate.didLoadingFailWithError(UserProfileError.missingAuthHeaders)
            return
        }
        
        let endpoint = "\(APIURL)/users/\(userId)"
        
        AF.request(endpoint, headers: authHeaders)
            .validate()
            .responseDecodable(of: User.self) { response in
                if let safeResponse = response.value {
                    self.delegate.didLoadUserData(safeResponse)
                    return
                }
                if let safeResponse = response.response {
                    self.handleError(forCode: safeResponse.statusCode)
                }
            }
    }

        func updateBio(newBio: String) {
            guard let authHeaders = AuthManager.shared.getAuthHeaders() else {
                delegate.didLoadingFailWithError(UserProfileError.missingAuthHeaders)
                return
            }
            
           
            let endpoint = "\(APIURL)/update_bio"
            
            let parameters: [String: Any] = [
                "bio": newBio
            ]
            
            AF.request(endpoint, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        self.delegate.didUpdateUserData()
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode {
                            self.handleError(forCode: statusCode)
                        } else {
                            self.delegate.didLoadingFailWithError(error)
                        }
                    }
                }
        }
    
    func changePassword(oldP: String, newP: String) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else {
            delegate.didLoadingFailWithError(UserProfileError.missingAuthHeaders)
            return
        }

        let endpoint = "\(APIURL)/change-password/"
        
        let parameters: [String: Any] = [
            "oldPassword": oldP,
            "newPassword": newP
        ]

        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: authHeaders)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    self.delegate.didUpdateUserData()
                    
                case .failure(let error):
                    
                    if let statusCode = response.response?.statusCode {
                        
                        self.handleError(forCode: statusCode)
                    } else {
                        self.delegate.didLoadingFailWithError(error)
                    }
                }
            }
    }
    
    func uploadAvatar(image: UIImage) {
            guard let authHeaders = AuthManager.shared.getAuthHeaders() else {
                delegate.didLoadingFailWithError(UserProfileError.missingAuthHeaders)
                return
            }

            let endpoint = "\(APIURL)/users/avatar"

            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                return
            }

            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "avatar", fileName: "profile.jpg", mimeType: "image/jpeg")
            }, to: endpoint, method: .post, headers: authHeaders)
            .validate()
 
            .responseDecodable(of: AvatarResponse.self) { response in
                
                switch response.result {
    
                case .success(let data):
                    self.delegate.didUpdateAvatar(newUrl: data.photo_uri)
                    self.delegate.didUpdateUserData()
                    
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        self.handleError(forCode: statusCode)
                    } else {
                        self.delegate.didLoadingFailWithError(error)
                    }
                }
            }
        }
    
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 500:
            delegate.didLoadingFailWithError(UserProfileError.noData)
        default:
            delegate.didLoadingFailWithError(UserProfileError.unexpected(code: responseCode))
        }
    }
}

