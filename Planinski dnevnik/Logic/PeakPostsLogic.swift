import Foundation
import Alamofire

protocol PeakPostsLogicDelegate {
    func didFetchPeakPosts(_ posts: [Post])
    func didFetchingPeakPostsFailWithError(_ error: String)
}

class PeakPostsLogic {
    private var delegate: PeakPostsLogicDelegate
    
    init(delegatingActionsTo delegate: PeakPostsLogicDelegate) {
        self.delegate = delegate
    }
    
    func retrievePeakPosts(forPeakWithId id: Int) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/peaks/\(id)/", headers: authHeaders)
            .validate()
            .responseDecodable(of: [Post].self) { response in
                if let safeResponse = response.value {
                    self.delegate.didFetchPeakPosts(safeResponse)
                    return
                }
                if let failure = response.response {
                    self.delegate.didFetchingPeakPostsFailWithError(String(failure.statusCode))
                }
            }

    }
}
