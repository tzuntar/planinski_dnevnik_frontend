import UIKit

class HikePeakEntryController: UIViewController {
    
    @IBOutlet weak var peakNameDropdown: DropdownTextField!
    @IBOutlet weak var peakAltitudeField: UITextField!
    @IBOutlet weak var peakCountryDropdown: DropdownTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // peakNameDropdown.setOptions(["Triglav", "Jalovec", "Razor", "Škrlatica"])
    }
    
    @IBAction func backButtonPressed() {
    }
    
    @IBAction func nextButtonPressed() {
    }
    
}
