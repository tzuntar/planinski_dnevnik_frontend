import UIKit

class UserProfileController: UIViewController {
    @IBOutlet weak var userProfilePhoto: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userBioLabel: UITextView!
    @IBOutlet weak var userNoPostsLabel: UILabel!
    @IBOutlet weak var userPostsTable: UITableView!
    
    // this gets set by the presenting controller
    var userId: Int?
    
    private var userPosts: [Post]?
    private var userLogic: UserLogic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPostsTable.register(UINib(nibName: "JournalPostCell", bundle: nil),
                                forCellReuseIdentifier: "JournalPostCell")
        userPostsTable.dataSource = self
        self.userLogic = UserLogic(delegatingActionsTo: self)
        self.userLogic!.retrieveData(for: userId!)
    }
    
    @IBAction func backButtonPressed() {
        self.dismiss(animated: true)
    }
}

// MARK: - User Logic Delegate
extension UserProfileController: UserProfileDelegate {
    func didLoadUserData(_ user: User) {
        if user.photo_path != nil {
            userProfilePhoto.loadFrom(URLAddress: "\(APIURL)/\(user.photo_path!)")
        }
        userNameLabel.text = user.name
        userBioLabel.text = user.bio
        userNoPostsLabel.isHidden = user.posts?.count ?? 0 > 0
        userPosts = user.posts
        userPostsTable.reloadData()
    }
    
    func didLoadingFailWithError(_ error: any Error) {
        // TODO: error popup
        self.dismiss(animated: true)
    }
}

// MARK: - User Posts Table Data Source
extension UserProfileController: UITableViewDataSource {
    // vraca stevilo vrstic podatkov
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userPosts?.count ?? 0    // userPosts.count ce ta ni nil, sicer 0
    }
    
    // napolni dano vrstico s podatki
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalPostCell", for: indexPath) as! JournalPostCell
        if userPosts != nil && userPosts?.count ?? 0 > 0 {
            if indexPath.row < userPosts!.count {
                cell.configure(with: userPosts![indexPath.row])
                return cell
            }
        }
        return cell
    }
}
