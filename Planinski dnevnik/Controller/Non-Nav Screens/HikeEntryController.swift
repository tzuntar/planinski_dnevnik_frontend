import UIKit
import CoreLocation

class HikeEntryController : UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var publicPostToggle: UISwitch!
    @IBOutlet weak var weatherToggle: UISwitch!
    @IBOutlet weak var selectedPhotoView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!

    @IBOutlet weak var currentWeatherField: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    @IBOutlet weak var currentWeatherLabel: UILabel!

    // MARK: - Instance vars
    private var photoPicker: UIImagePickerController?
    private var selectedPhoto: UIImage?

    /** Used when editing an existing post; should be unset on new posts **/
    var existingHike: Post?

    //za lokacijo
    let locationManager = CLLocationManager()
    let weatherLogic = WeatherLogic()
    var currentWeather: String?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        nextButton.isEnabled = false
    
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        selectedPhotoView.isUserInteractionEnabled = true
        selectedPhotoView.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(selectedPhotoPressed)))
        initPhotoPicker()

        if existingHike != nil {
            configure(forPost: existingHike!)
            viewTitleLabel.text = "Uredi vzpon"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowHikePeakScreen" {
            guard let data = sender as? HikeEntryData else { return }
            let vc = segue.destination as! HikePeakEntryController
            vc.hikeEntryData = data
        }
    }

    /** Configure for an existing post */
    func configure(forPost post: Post) {
        existingHike = post

        nameField.text = post.name
        descriptionField.text = post.description
        publicPostToggle.isOn = post.is_public == 1
        if let weather = post.weather {
            weatherToggle.isOn = true
            displayWeather(from: weather)
        } else {
            weatherToggle.isOn = false
        }
    
        let imageUrl = "\(APIURL)/\(post.photo_path)"
        selectedPhotoView.loadFrom(URLAddress: imageUrl)
        selectedPhoto = selectedPhotoView.image
    
        nextButton.isEnabled = true
    }
    
    // MARK: - IBActions
    @IBAction func backButtonPressed() {
        self.dismiss(animated: true)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        guard let name = nameField.text,
              let description = descriptionField.text else { return }

        let peakEntry: PeakEntry? = (existingHike != nil && existingHike!.peak != nil)
            ? PeakEntry(name: existingHike!.peak!.name,
                        altitude: existingHike!.peak!.altitude,
                        country_id: existingHike!.peak!.country_id)
            : nil

        let entry = HikeEntry(name: name,
                              description: description,
                              is_public: publicPostToggle.isOn,
                              weather: currentWeather,
                              peak: peakEntry)

        guard let selectedPhoto = selectedPhoto else { return }

        performSegue(withIdentifier: "ShowHikePeakScreen",
                     sender: HikeEntryData(hikeEntry: entry, hikePhoto: selectedPhoto))
    }

    @IBAction func textFieldTextChanged() {
        nextButton.isEnabled = !nameField.text!.isEmpty
            && !descriptionField.text!.isEmpty
            && selectedPhoto != nil
    }

    @IBAction func weatherSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            currentWeatherField.isHidden = false
            currentWeatherLabel.isHidden = false
            weatherIconView.isHidden = false
            currentWeatherField.text = "Nalaganje..."
            locationManager.requestLocation()
        } else {
            currentWeatherField.isHidden = true
            currentWeatherLabel.isHidden = true
            weatherIconView.isHidden = true
            currentWeatherField.text = ""
            currentWeather = ""
        }
    }
    
    @objc func selectedPhotoPressed() {
        showPhotoPicker()
    }

    // MARK: - Helper Methods
    private func displayWeather(from dataString: String) {
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
}

// MARK: - Location Manager Delegate
extension HikeEntryController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
            weatherToggle.isEnabled = true
            weatherToggle.isOn = true
            currentWeatherField.isHidden = false
            weatherIconView.isHidden = false
            currentWeatherField.text = "Nalaganje..."
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
        guard let location = locations.first else { return }
        // kliče vreme z dobljenimi koordinatami
        weatherLogic.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude) { [weak self] weatherInfo in
            
            DispatchQueue.main.async {
                if let responseWeather = weatherInfo {
                    self?.currentWeather = responseWeather
                    self?.displayWeather(from: responseWeather)
                } else {
                    self?.currentWeather = nil
                    self?.currentWeatherField.text = "Napaka"
                }
            }
        }
    }

    //brez tega ocitno ne dela
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Napaka pri pridobivanju lokacije: \(error)")
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

// MARK: - Load image from url (ne obstaja loadFrom(url), to sm pa iz nek prekopirov lp mark)
extension UIImageView{
    func loadFrom(url: String){
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url){
                DispatchQueue.main.async {
                    self.image = UIImage(data:data)
                }
            }
        }
    }
}
