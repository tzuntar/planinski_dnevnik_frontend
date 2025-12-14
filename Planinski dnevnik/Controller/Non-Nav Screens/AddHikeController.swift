import UIKit

class AddHikeController : UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var peakNameField: UITextField!
    @IBOutlet weak var publicPostToggle: UISwitch!
    @IBOutlet weak var selectedPhotoView: UIImageView!
    @IBOutlet weak var addHikeButton: UIButton!
    
    private var hikeLogic: HikeLogic?
    
    private var photoPicker: UIImagePickerController?
    private var selectedPhoto: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        hikeLogic = HikeLogic(delegate: self)
        
        addHikeButton.isEnabled = false
        selectedPhotoView.isUserInteractionEnabled = true
        selectedPhotoView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action: #selector(selectedPhotoPressed)))
        initPhotoPicker()
    }

    @IBAction func backButtonPressed() {
        self.dismiss(animated: true)
    }
    
    @objc func selectedPhotoPressed() {
        showPhotoPicker()
    }

    @IBAction func addHikePressed(_ sender: UIButton) {
        guard let name = nameField.text,
              let description = descriptionField.text,
              let peak = peakNameField.text else { return }
        
        sender.isEnabled = false
        nameField.isEnabled = false
        descriptionField.isEnabled = false
        peakNameField.isEnabled = false
        publicPostToggle.isEnabled = false
        selectedPhotoView.isUserInteractionEnabled = false
        let entry = HikeEntry(name: name,
                              description: description,
                              peak: peak,
                              is_public: publicPostToggle.isOn,
                              user_id: AuthManager.shared.session!.user.id)
        guard let selectedPhoto = selectedPhoto else { return }
        hikeLogic!.postHike(with: entry, photo: selectedPhoto)
    }

    @IBAction func textFieldTextChanged() {
        addHikeButton.isEnabled = !nameField.text!.isEmpty
            && !descriptionField.text!.isEmpty
            && !peakNameField.text!.isEmpty
            && selectedPhoto != nil
    }
}

// MARK: - Photo Picker Delegate
extension AddHikeController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func initPhotoPicker() {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) { return }
        photoPicker = UIImagePickerController()
        guard let picker = photoPicker else { return }
        picker.delegate = self
        picker.sourceType = .photoLibrary
        if let types = UIImagePickerController.availableMediaTypes(for: picker.sourceType) {
            if !types.contains("public.image") { return }
        }
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true
    }
    
    private func showPhotoPicker() {
        guard let picker = photoPicker else { return }
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let photo = info[.originalImage] as? UIImage else { return }
        selectedPhoto = photo
        selectedPhotoView.image = photo
        self.textFieldTextChanged() // to re-check for selected photo and enable the submit button
    }
}

// MARK: - Add Hike Delegate
extension AddHikeController : AddHikeDelegate {
    func didAddHike(_ post: Post) {
        self.dismiss(animated: true)
    }
    
    func didPostProgressChange(toFraction fractionCompleted: Double) {
        print("Upload progress: \(fractionCompleted)")
    }
    
    func didAddingFailWithError(_ error: any Error) {
        addHikeButton.isEnabled = true
        nameField.isEnabled = true
        descriptionField.isEnabled = true
        peakNameField.isEnabled = true
        publicPostToggle.isEnabled = true
        selectedPhotoView.isUserInteractionEnabled = true
    }
}
