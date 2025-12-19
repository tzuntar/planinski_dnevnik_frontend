import UIKit
import CoreLocation

class HikeEntryController : UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var peakNameField: UITextField!
    @IBOutlet weak var publicPostToggle: UISwitch!
    @IBOutlet weak var weatherToggle: UISwitch!
    @IBOutlet weak var selectedPhotoView: UIImageView!
    @IBOutlet weak var addHikeButton: UIButton!

    @IBOutlet weak var currentWeatherField: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    
    @IBOutlet weak var currentWeatherLabel: UILabel!
  
    private var hikeLogic: HikeLogic?
    
    private var photoPicker: UIImagePickerController?
    private var selectedPhoto: UIImage?

    // used when editing an existing post; should be unset on new posts
    var existingHike: Post?
    
    //za lokacijo
    let locationManager = CLLocationManager()
    let weatherLogic = WeatherLogic()
    var currentWeather: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        hideKeyboardWhenTappedAround()
        hikeLogic = HikeLogic(delegate: self)
        
        addHikeButton.isEnabled = false
        selectedPhotoView.isUserInteractionEnabled = true
        selectedPhotoView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                      action: #selector(selectedPhotoPressed)))
        initPhotoPicker()
        if existingHike != nil {
            configure(forPost: existingHike!)
            viewTitleLabel.text = "Uredi vzpon"
        }
    }
    

    
    @IBAction func weatherSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
                currentWeatherField.isHidden = false
                currentWeatherLabel.isHidden = false
                weatherIconView.isHidden = false
            
                currentWeatherField.text = "Nalagam..."
            
                locationManager.requestLocation()
                
             
            } else {
                currentWeatherField.isHidden = true
                currentWeatherLabel.isHidden = true
                weatherIconView.isHidden = true
                
                currentWeatherField.text = ""
                currentWeather = ""
            }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.requestLocation()
                weatherToggle.isEnabled = true
                weatherToggle.isOn = true
                currentWeatherField.isHidden = false
                weatherIconView.isHidden = false
                currentWeatherField.text = "Nalagam..."
                currentWeatherLabel.isHidden = false
            } else {
                weatherToggle.isOn = false
                weatherToggle.isEnabled = false
                weatherIconView.isHidden = true
                currentWeatherField.isHidden = true
                currentWeatherField.text = ""
                currentWeatherLabel.isHidden = true
            }
        }
    
    //ko dobi koordinate
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                // kliče vreme z dobljenimi koordinatami
                weatherLogic.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] weatherInfo in
                    
                    DispatchQueue.main.async {
                        if let responseWeather = weatherInfo {
                            self?.currentWeather = responseWeather
                            self?.displayWeather(from: responseWeather)
                        } else {
                            self?.currentWeather = nil
                            self?.currentWeatherField.text = "Napaka!"
                        }
                    }
                }
            }
        }
    
    //brez tega ocitno ne dela
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Napaka pri pridobivanju lokacije: \(error)")
    }
    
    func displayWeather(from dataString: String) {
            let parts = dataString.components(separatedBy: ";")
            
            if parts.count >= 3 {
                // per partes ;))
                let description = parts[0]
                let temperature = parts[1]
                let iconURL = parts[2]
                
                currentWeatherField.text = "\(description), \(temperature)°C"
                
                weatherIconView.isHidden = false
                weatherIconView.loadFrom(url: iconURL)
                
            } else {
                print("Napaka: Nepravilen format podatkov o vremenu.")
            }
        }
    
    func configure(forPost post: Post) {
        // TODO: Tobija
        existingHike = post
        nameField.text = post.name
        descriptionField.text = post.description
        //publicPostToggle.isOn = post.is_public
        selectedPhotoView.loadFrom(URLAddress: "\(APIURL)/\(post.photo_path)")
        addHikeButton.isEnabled = true
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
              let weather = currentWeather,
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
                              weather: weather,
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
extension HikeEntryController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
extension HikeEntryController : AddHikeDelegate {
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

// MARK: - Load image from url (ne obstaja loadFrom(url), to sm pa iz nek prekopirov lp mark)
extension UIImageView{
    func loadFrom(url: String){
        
        guard let url = URL(string: url) else {
            return
        }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url){
                DispatchQueue.main.async {
                    self.image = UIImage(data:data)
                }
            }
        }
    }
}
