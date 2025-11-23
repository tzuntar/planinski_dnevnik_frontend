import UIKit

class FeedPostCell : UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var PostUserLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadPost(_ post: Post) {
        
    }
}
