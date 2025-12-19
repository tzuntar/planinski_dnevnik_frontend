import UIKit

class ProfileViewController : UIViewController {
    
    private var currentUser: User?
    
    @IBOutlet weak var bioTextBox: UITextField!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    private lazy var userLogic = UserLogic(delegatingActionsTo: self)
    
    private var originalBio: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = AuthManager.shared.session?.user
        
        bioTextBox.layer.cornerRadius = 8
        usernameLabel.text = currentUser?.name
        
        let currentBio = currentUser?.bio
        bioTextBox.text = currentBio
        originalBio = currentBio ?? ""
        // TODO: Fetch image, recent vzponi, display name...
    
    }
    
    
    @IBAction func bioTextFieldEditingDidEnd(_ sender: UITextField) {
        
        guard let newText = sender.text else { return }
                
                if newText != originalBio {
                    userLogic.updateBio(newBio: newText)
                    
                    originalBio = newText
                }
    }
    
    @IBAction func navToFeedPressed() {
        // yes, it's technically its parent. yes, it's two levels higher in the hierarchy.
        if let parentVC = self.parent?.parent?.parent as? HomeSwipeController {
            parentVC.moveToPage(HomeSwipeController.PagesIndex.FeedPage.rawValue, animated: true)
        }
    }

    @IBAction func logOutPressed() {
        AuthManager.shared.endSession()
        let loginStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        let loginController = loginStoryboard.instantiateViewController(withIdentifier: "LoginVC")
        loginController.modalPresentationStyle = .fullScreen
        present(loginController, animated: true, completion: nil)
    }
}

extension ProfileViewController: UserProfileDelegate {
    
    func didLoadUserData(_ user: User) {
        self.currentUser = user
    }
    
    func didUpdateUserData() {
        //TODO:
    }
    
    func didLoadingFailWithError(_ error: any Error) {
        var message = error.localizedDescription;
        if let error = error as? UserProfileError {
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
