import UIKit

class RegisterController: UIViewController{
    
    //Data Fields
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
  
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    //Buttons
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    //Error labels
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    lazy var errorLabels: [UILabel] = [
        emailErrorLabel,
    ]
    
    //Error Messages
    let emptyErrorMessage = "Polje ne sme biti prazno."
    
    
    let registrationLogic = RegisterLogic()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        registrationLogic.delegate = self  // plugs this class into RegisterLogic as its delegate
    }
    

    //Actions
    
    // back button dismisses the current view
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        clearErrorLabels()
        
        var hasError: Bool = false
        
        let email: String = emailField.text ?? ""
        let username: String = usernameField.text ?? ""
        let password: String = passwordField.text ?? ""
        let confirmPassword: String = confirmPasswordField.text ?? ""
        
        
        if (email.isEmpty){
            emailErrorLabel.text = emptyErrorMessage
            hasError = true
        } else if !email.contains("@") || !email.contains(".") { // čist basic email validacija
            emailErrorLabel.text = "Prosimo preverite vse podatke."
            hasError = true
        }
        if (username.isEmpty){
            emailErrorLabel.text = emptyErrorMessage
            hasError = true
        }
        if (password.isEmpty){
            emailErrorLabel.text = emptyErrorMessage
            hasError = true
        } else if (confirmPassword != password){
            emailErrorLabel.text = "Prosimo preverite vse podatke."
            hasError = true
        }
        if (hasError){
            return
        }
        
        registrationLogic.attemptRegistration(with: RegisterEntry(email: email, password: password, name: username))
        
    }
    
    // Helper Functions
    
    func clearErrorLabels(){
        for errorLabel in errorLabels {
            errorLabel.text = ""
        }
    }

}

extension RegisterController : RegisterDelegate {
    func didRegisterUser(_ session: UserSession) {
        AuthManager.shared.startSession(session)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let feedVC = mainStoryboard.instantiateViewController(withIdentifier: "swipe-vc")
        feedVC.modalPresentationStyle = .fullScreen
        present(feedVC, animated: true, completion: nil)
    }
    
    func didRegisterFailWithError(_ error: any Error) {
        var message = error.localizedDescription;
        if let error = error as? RegisterError {
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
