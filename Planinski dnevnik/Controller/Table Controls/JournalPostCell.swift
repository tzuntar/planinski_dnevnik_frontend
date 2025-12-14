import UIKit

class JournalPostCell : UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        postImageView.layer.cornerRadius = 10
    }

    func configure(with post: Post) {
        postTitleLabel.text = post.name
        postDescriptionLabel.text = post.description
        postImageView.loadFrom(URLAddress: "\(APIURL)/\(post.photo_path)")
    }
}
