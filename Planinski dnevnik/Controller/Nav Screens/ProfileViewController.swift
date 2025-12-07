import UIKit

class ProfileViewController : UIViewController {
    
    private var currentUser: User?
    
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = AuthManager.shared.session?.user
        
        bioLabel.layer.cornerRadius = 8
        bioLabel.text = currentUser?.bio
        usernameLabel.text = currentUser?.name
        // TODO: Fetch image, recent vzponi, display name...
    
    }
    
    @IBAction func navToFeedPressed() {
        // yes, it's technically its parent. yes, it's two levels higher in the hierarchy.
        if let parentVC = self.parent?.parent?.parent as? HomeSwipeController {
            parentVC.moveToPage(HomeSwipeController.PagesIndex.FeedPage.rawValue, animated: true)
        }
    }
}

extension ProfileViewController: UserAccountDelegate {
    
    func didLoadUserData(_ user: User) {
        self.currentUser = user
    }
    
    func didLoadingFailWithError(_ error: any Error) {
        var message = error.localizedDescription;
        if let error = error as? UserAccountError {
            message = error.description
        }
        let alert = UIAlertController(
            title: "Napaka",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
