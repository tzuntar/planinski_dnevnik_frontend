import UIKit

protocol FeedPostCellDelegate: AnyObject {
    func feedPostCell(_ cell: FeedPostCell, didTapUserWithId id: Int)
}

class FeedPostCell : UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var postUserButton: UIButton!
    
    private var userId: Int?
    weak var delegate: FeedPostCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        postImageView.layer.cornerRadius = 10
    }
    
    func configure(with post: Post) {
        postTitleLabel.text = post.name
        postDescriptionLabel.text = post.description
        postImageView.loadFrom(URLAddress: "\(APIURL)/\(post.photo_path)")
        postUserButton.setTitle(post.user?.name, for: .normal)
        userId = post.user_id
    }

    @IBAction private func userTapped() {
        guard let userId = self.userId else { return }
        delegate?.feedPostCell(self, didTapUserWithId: userId)
    }
}
