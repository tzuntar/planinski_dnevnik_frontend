//
//  ActivityCell.swift
//  Planinski dnevnik
//
//  Created by Mark Horvat on 23. 11. 25.
//

import UIKit

class ActivityCell: UITableViewCell {

    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var activityLocation: UILabel!
    @IBOutlet weak var activityHeight: UILabel!
    @IBOutlet weak var activityDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadPost(_ post: Post) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
