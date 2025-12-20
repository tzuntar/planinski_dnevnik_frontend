import UIKit
import Alamofire

protocol AddHikeDelegate {
    func didAddHike(_ post: Post)
    func didPostProgressChange(toFraction fractionCompleted: Double)
    func didAddingFailWithError(_ error: Error)
}

struct HikeEntry: Encodable {
    let name: String?
    let description: String?
    let is_public: Bool?
    let weather: String?
    let peak: PeakEntry?
}

struct PeakEntry: Encodable {
    let name: String?
    let altitude: Int?
    let country_id: Int?
    let country: String?
}

enum AddHikeError: Error, CustomStringConvertible {
    case dataMissing
    case unexpected(code: Int)
    
    public var description: String {
        switch self {
        case .dataMissing:
            return "Manjka zahtevan podatek"
        case .unexpected(_):
            return "Neznana napaka"
        }
    }
}

class HikeLogic {
    let delegate: AddHikeDelegate
    
    init(delegate: AddHikeDelegate) {
        self.delegate = delegate
    }
    
    func postHike(with entry: HikeEntry, photo: UIImage) {
        guard let entryData = objectToUtf8Data(entry) else { return }
        guard var authHeaders = AuthManager.shared.getAuthHeaders() else { return }

        AF.upload(
            multipartFormData: { multiPart in
                multiPart.append(
                    photo.jpegData(compressionQuality: 0.8)!,
                    withName: "photo",
                    fileName: "photo.jpg",
                    mimeType: "image/jpeg"
                )
                multiPart.append(
                    entryData,
                    withName: "journal_entry",
                    mimeType: "application/json"
                )
            },
            to: "\(APIURL)/journal_entries",
            method: .post,
            headers: authHeaders
        )
        .uploadProgress(queue: .main) { progress in
            self.delegate.didPostProgressChange(toFraction: progress.fractionCompleted)
        }
        .responseDecodable(of: Post.self) { response in
            if let safeResponse = response.value {
                self.delegate.didAddHike(safeResponse)
                return
            }
            if let failure = response.response {
                self.delegate.didAddingFailWithError(FeedError.unexpected(code: failure.statusCode));
            }
        }
    }
    
    private func objectToUtf8Data(_ object: Encodable, _ encoder: JSONEncoder = JSONEncoder()) -> Data? {
        var data: Data
        do {
            data = try encoder.encode(object)
        } catch { return nil }
        return data
    }
}
