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
        postTitleLabel.text = post.name
        postDescriptionLabel.text = post.description
        postImageView.loadFrom(URLAddress: "\(APIURL)/\(post.photo_path)")
        //postUserLabel.text = post.user_name
    }
}
