import UIKit

class PeakPostCell : JournalPostCell {
    override func configure(with post: Post) {
        super.configure(with: post)
        peakField.text = post.user?.name
    }
}
