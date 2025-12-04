import UIKit

class FeedPostCell : UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var postUserLabel: UILabel!
    
    private	var post: Post?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadPost(_ post: Post) {
        self.post = post
        postTitleLabel.text = post.title
        postDescriptionLabel.text = post.description
        postImageView.loadFrom(URLAddress: "\(APIURL)/content/\(post.photo_url)")
        postUserLabel.text = post.user_name
    }
}
