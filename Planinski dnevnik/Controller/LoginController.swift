import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    let loginLogic = LoginLogic()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        loginLogic.delegate = self  // plugs this class into LoginLogic as its delegate
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let username = usernameField.text, username.count > 0 else { return }
        guard let password = passwordField.text, password.count > 0 else { return }
        loginLogic.attemptLogin(with: LoginEntry(email: username, password: password))
    }

}

// extension that handles the delegate methods. There's no diff between writing the code
// in the class itself or in the extension, but it's nice to separate methods of each
// delegated protocol into its own extension.
extension LoginController: LoginDelegate {
    func didLogInUser(_ session: UserSession) {
        AuthManager.shared.startSession(session)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let feedVC = mainStoryboard.instantiateViewController(withIdentifier: "swipe-vc")
        feedVC.modalPresentationStyle = .fullScreen
        present(feedVC, animated: true, completion: nil)
    }
    
    func didLoginFailWithError(_ error: any Error) {
        var message = error.localizedDescription;
        if let error = error as? LoginError {
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
