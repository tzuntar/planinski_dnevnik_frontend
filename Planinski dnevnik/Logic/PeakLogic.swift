import Foundation
import Alamofire

protocol PeakLogicDelegate {
    func didFetchPeaks(_ peaks: [Int : Peak])
    func didFetchCountries(_ countries: [Int : String])
    func didFetchingPeaksFailWithError(_ error: String)
    func didFetchingCountriesFailWithError(_ error: String)
}

class PeakLogic {
    private let delegate: PeakLogicDelegate
    
    init(delegatingActionsTo delegate: PeakLogicDelegate) {
        self.delegate = delegate
    }

    func fetchPeaks() {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/peaks/", headers: authHeaders)
            .validate()
            .responseDecodable(of: [Peak].self) { response in
                if let safeResponse = response.value {
                    let peaksDict = Dictionary(uniqueKeysWithValues: safeResponse.map { ($0.id, $0) })
                    self.delegate.didFetchPeaks(peaksDict)
                    return
                }
                if let failure = response.response {
                    self.delegate.didFetchingPeaksFailWithError(String(failure.statusCode))
                }
            }
    }

    func fetchCountries() {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/countries/", headers: authHeaders)
            .validate()
            .responseDecodable(of: [Country].self) { response in
                if let safeResponse = response.value {
                    let countries = Dictionary(uniqueKeysWithValues: safeResponse.map { ($0.id, $0.name) })
                    self.delegate.didFetchCountries(countries)
                    return
                }
                if let failure = response.response {
                    self.delegate.didFetchingCountriesFailWithError(String(failure.statusCode))
                }
            }
    }
}
