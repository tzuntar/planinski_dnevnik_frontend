import UIKit

class ProfileViewController : UIViewController {
    
    private var currentUser: User?
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var bioTextBox: UITextView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var imagePicker = UIImagePickerController()

    
    private lazy var userLogic = UserLogic(delegatingActionsTo: self)
    
    private var originalBio: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = AuthManager.shared.session?.user
        
        bioTextBox.layer.cornerRadius = 10
        usernameLabel.text = currentUser?.name
        
        profilePictureView.layer.cornerRadius = profilePictureView.frame.height / 2
            profilePictureView.clipsToBounds = true
        
        let tapPhotoMenu = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
            profilePictureView.isUserInteractionEnabled = true
        profilePictureView.addGestureRecognizer(tapPhotoMenu)
        
        imagePicker.delegate = self
        
        let currentBio = currentUser?.bio
        bioTextBox.text = currentBio
        originalBio = currentBio ?? ""
        
        if let photoUrl = currentUser?.photo_uri {
            let fullUrl = "\(APIURL)\(photoUrl)"
            self.profilePictureView.loadFrom(url: fullUrl)
            }
    

        if let userId = currentUser?.id {
                userLogic.retrieveData(for: userId)
            }
        
        
        bioTextBox.delegate = self
    
    }
    
    @objc func profilePictureTapped() {
        let alert = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                self.openCamera()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }

    func openGallery() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        print("changePassword btn pressed")
        
    }
    
    @IBAction func bioTextFieldEditingDidEnd(_ sender: UITextView) {
        
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


extension ProfileViewController: UserProfileDelegate, UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let newText = textView.text else { return }
        
        if newText != originalBio {
            userLogic.updateBio(newBio: newText)
            originalBio = newText
        }
    }
    
    func didLoadUserData(_ user: User) {
        self.currentUser = user
    }
    
    func didUpdateAvatar(newUrl: String) {
        print("uspešen upload")
            self.profilePictureView.loadFrom(url: newUrl)
        print(newUrl)
    }
    
    func didUpdateUserData() {
        let alert = UIAlertController(
            title: "Profile updated",
            message: "User bio updated.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
        
        self.present(alert,animated:true,completion: nil)
        
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    
        if let image = info[.editedImage] as? UIImage {
            
            self.profilePictureView.image = image
            
           
            userLogic.uploadAvatar(image: image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

