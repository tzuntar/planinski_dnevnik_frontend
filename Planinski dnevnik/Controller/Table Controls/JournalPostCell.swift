import UIKit

class JournalPostCell : UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    
    private var post: Post?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadPost(_ post: Post) {
        self.post = post
        postTitleLabel.text = post.name
        postDescriptionLabel.text = post.description
        postImageView.loadFrom(URLAddress: "\(APIURL)/\(post.photo_path)")
    }
}
