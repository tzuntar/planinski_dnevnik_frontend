import Foundation
import Alamofire


protocol RegisterDelegate {
    func didRegisterUser(_ session: UserSession)
    func didRegisterFailWithError(_ error: Error)
}

struct RegisterEntry: Encodable{
    let email:String
    let password:String
    let name:String
    
    init(email: String, password: String, name: String) {
        self.email = email
        self.password = password
        self.name = name    // more bit name ne username
    }
}

enum RegisterError: Error, CustomStringConvertible {
    case missingData
    case serverSideError
    case unexpected(code: Int)
    
    //client errors bi mel
    //case usernameExits
    //case emailExists

    
    public var description: String{ // requirement od CustomStringConvertible
        switch self { // Če ne pokriješ vseh zgori definiranih case-ov ne compila.
        case .missingData:
            return "Prosimo, vnesite vse podatke"
        case .serverSideError:
            return "Registracija spodletela"
        case .unexpected(_):
            return "Neznana napaka"
        }
    }

}

class RegisterLogic{
    
    var delegate: RegisterDelegate?
    
    func attemptRegistration(with registerEntry: RegisterEntry){
        AF.request(APIURL + "/auth/register",
                   method: .post,
                   parameters: registerEntry,
                   encoder: JSONParameterEncoder.default)
                    .validate()
                    .responseDecodable(of: UserSession.self){
                        // ko server vrne UserSession, je response valid, koda ni važna.
                        response in if let safeResponse = response.value {
                            self.delegate?.didRegisterUser(safeResponse)
                            return
                        }
                        // ko server namesto UserSession vrne samo kodo.
                        if let httpResponse = response.response{
                            self.handleError(forCode: httpResponse.statusCode)
                        }
                        
                       
                    }
    }
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 500:
            delegate?.didRegisterFailWithError(RegisterError.serverSideError)
        case 400:
            delegate?.didRegisterFailWithError(RegisterError.missingData)
        default:
            delegate?.didRegisterFailWithError(LoginError.unexpected(code: responseCode))
        }
    }
    
}
