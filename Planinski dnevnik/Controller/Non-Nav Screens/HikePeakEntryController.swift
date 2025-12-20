import UIKit

struct HikeEntryData {
    /** Hike Entry from the previous step */
    var hikeEntry: HikeEntry?
    /** Hike photo from the previous step */
    var hikePhoto: UIImage?
    /** Should be set if editing an existing post */
    var existingPost: Post?
}

class HikePeakEntryController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var peakNameDropdown: DropdownTextField!
    @IBOutlet weak var peakAltitudeField: UITextField!
    @IBOutlet weak var peakCountryDropdown: DropdownTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Instance vars
    private var hikeLogic: HikeLogic?
    private var peakLogic: PeakLogic?
    private var existingPeaks: [Int : Peak]?
    private var existingCountries: [Int : String]?
    
    /** Set from presenting controller to pass data to this controller */
    var hikeEntryData: HikeEntryData?

    override func viewDidLoad() {
        super.viewDidLoad()
        hikeLogic = HikeLogic(delegate: self)
        peakLogic = PeakLogic(delegatingActionsTo: self)
        
        // do this in the background to not stall the UI
        DispatchQueue.global(qos: .background).async {
            self.peakLogic?.fetchPeaks()
            self.peakLogic?.fetchCountries()
        }
        
        if let existingPostPeak = hikeEntryData?.existingPost?.peak {
            peakNameDropdown.text = existingPostPeak.name
            peakAltitudeField.text = String(existingPostPeak.altitude)
            // country gets to be set in the delegate below as the data for
            // the country names might not have loaded yet (async)
        }
    }
    
    // MARK: - IBActions
    @IBAction func backButtonPressed() {
        // TODO: keep peak data when returning
        self.dismiss(animated: true)
    }
    
    @IBAction func nextButtonPressed() {
        let peakEntry = PeakEntry(
            name: peakNameDropdown.text,
            altitude: Int(peakAltitudeField.text ?? "0"),
            country_id: nil
        )
        let entry = HikeEntry(
            name: hikeEntryData?.hikeEntry?.name,
            description: hikeEntryData?.hikeEntry?.description,
            is_public: hikeEntryData?.hikeEntry?.is_public,
            weather: hikeEntryData?.hikeEntry?.weather,
            peak: peakEntry
        )
        nextButton.isEnabled = false
        hikeLogic!.postHike(with: entry, photo: (hikeEntryData?.hikePhoto)!)
    }
}

// MARK: - Peak Logic Delegate
extension HikePeakEntryController: PeakLogicDelegate {
    func didFetchPeaks(_ peaks: [Int : Peak]) {
        DispatchQueue.main.async {
            self.existingPeaks = peaks
            self.peakNameDropdown.options = self.existingPeaks!.values.compactMap { $0.name }
        }
    }
    
    func didFetchCountries(_ countries: [Int : String]) {
        DispatchQueue.main.async {
            self.existingCountries = countries
            self.peakCountryDropdown.options = self.existingCountries!.values.compactMap { $0 }
            // since we have the names we can now load the country name for an existing post
            if let countryId = self.hikeEntryData?.existingPost?.peak?.country_id,
               let countryName = self.existingCountries?[countryId] {
                self.peakCountryDropdown.text = countryName
            }
        }
    }
    
    func didFetchingPeaksFailWithError(_ error: String) {
        print("Unable to fetch peaks: \(error)")
    }
    
    func didFetchingCountriesFailWithError(_ error: String) {
        print("Unable to fetch countries: \(error)")
    }
}

// MARK: - Add Hike Delegate
extension HikePeakEntryController: AddHikeDelegate {
    func didAddHike(_ post: Post) {
        self.dismiss(animated: true)
        self.presentingViewController?.dismiss(animated: true)
    }
    
    func didPostProgressChange(toFraction fractionCompleted: Double) {
        print("Upload progress: \(fractionCompleted)")
    }
    
    func didAddingFailWithError(_ error: any Error) {
        // TODO: show why it failed
        nextButton.isEnabled = true
    }
}
