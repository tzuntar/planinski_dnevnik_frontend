import UIKit

class PeakPostCell : JournalPostCell {
    override func configure(with post: Post) {
        super.configure(with: post)
        let dateStr = Utilities.backendDateToEuropeanString(post.created_at) ?? ""
        peakField.text = "\(post.user!.name), \(dateStr)"
    }
}
