//
//  UserLogic.swift
//  Planinski dnevnik
//
//  Created by Mark Horvat on 24. 11. 25.
//

import Foundation
import Alamofire
import UIKit

protocol UserAccountDelegate{
    func didLoadUserData(_ user: User)
    func didLoadingFailWithError(_ error: Error)
}

enum UserAccountError: Error,CustomStringConvertible{
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
    var delegate: UserAccountDelegate?
    
    func retrieveData(for user: User) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else {
            delegate?.didLoadingFailWithError(UserAccountError.missingAuthHeaders)
            return
        }
        
        let endpoint = "\(APIURL)/users/\(user.id)AP"
        
        AF.request(endpoint, headers: authHeaders)
            .validate()
            .responseDecodable(of: User.self) { response in
                if let safeResponse = response.value {
                    self.delegate?.didLoadUserData(safeResponse)
                    return
                }
                if let safeResponse = response.response {
                    self.handleError(forCode: safeResponse.statusCode)
                }
            }
    }
    
    
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 500:
            delegate?.didLoadingFailWithError(UserAccountError.noData)
        default:
            delegate?.didLoadingFailWithError(UserAccountError.unexpected(code: responseCode))
        }
    }
}

