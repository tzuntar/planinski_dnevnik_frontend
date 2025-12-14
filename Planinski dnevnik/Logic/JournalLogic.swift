import Foundation
import Alamofire

protocol JournalDelegate {
    func didFetchPosts(_ posts: [Post])
    func didFetchingFailWithError(_ error: Error)
}

enum JournalError: Error, CustomStringConvertible {
    case noData
    case unexpected(code: Int)
    
    public var description: String {
        switch self {
        case .noData:
            return "Ni podatkov"
        case .unexpected(_):
            return "Napaka"
        }
    }
}

class JournalLogic {
    
    let delegate: JournalDelegate
    
    init(delegatingActionsTo delegate: JournalDelegate) {
        self.delegate = delegate
    }
    
    func retrievePosts() {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/journal_entries/", headers: authHeaders)
            .validate()
            .responseDecodable(of: [Post].self) { response in
                if let safeResponse = response.value {
                    self.delegate.didFetchPosts(safeResponse)
                    return
                }
                
                if let failure = response.response {
                    self.handleError(forCode: failure.statusCode)
                }
            }
    }
    
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 500:
            delegate.didFetchingFailWithError(JournalError.noData)
        default:
            delegate.didFetchingFailWithError(JournalError.unexpected(code: responseCode))
        }
    }
    
}
