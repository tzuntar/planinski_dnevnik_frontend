import UIKit

class JournalPostCell : UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var peakField: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }

    func configure(with post: Post) {
        postTitleLabel.text = post.name
        postDescriptionLabel.text = post.description
        postImageView.loadFrom(URLAddress: "\(APIURL)/\(post.photo_path)")
        if let peak = post.peak {
            let dateStr = ISO8601DateFormatter().date(from: post.created_at)?.formatted() ?? ""
            peakField.text = "\(peak.name), \(peak.altitude) m.n.v. \(dateStr)"
        }
    }
}
