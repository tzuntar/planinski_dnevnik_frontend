import Foundation
import Alamofire

protocol FeedDelegate {
    func didFetchPosts(_ posts: [Post])
    func didFetchingFailWithError(_ error: Error)
}

enum FeedError: Error, CustomStringConvertible {
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

class FeedLogic {
    
    let delegate: FeedDelegate
    
    init(delegatingActionsTo delegate: FeedDelegate) {
        self.delegate = delegate
    }
    
    func retrievePosts() {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/feed/posts", headers: authHeaders)
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
            delegate.didFetchingFailWithError(FeedError.noData)
        default:
            delegate.didFetchingFailWithError(FeedError.unexpected(code: responseCode))
        }
    }
    
}
