import UIKit

class PeakProfileController: UIViewController {
    @IBOutlet weak var peakNameLabel: UILabel!
    @IBOutlet weak var peakDescriptionLabel: UILabel!
    @IBOutlet weak var peakNoPostsLabel: UILabel!
    @IBOutlet weak var peakPostsTable: UITableView!
    
    // this gets set by the presenting controller
    var peak: Peak?
    
    private var peakPosts: [Post]?
    private var peakPostsLogic: PeakPostsLogic?

    override func viewDidLoad() {
        super.viewDidLoad()
        peakPostsTable.register(UINib(nibName: "PeakPostCell", bundle: nil),
                                forCellReuseIdentifier: "PeakPostCell")
        peakPostsTable.dataSource = self

        peakPostsLogic = PeakPostsLogic(delegatingActionsTo: self)
    
        peakDescriptionLabel.text = "\(peak!.altitude) m.n.v."
        peakPostsLogic!.retrievePeakPosts(forPeakWithId: peak!.id)
    }
    
    @IBAction func backButtonPressed() {
        self.dismiss(animated: true)
    }
}

// MARK: - Peak Logic Delegate
extension PeakProfileController: PeakPostsLogicDelegate {
    func didFetchPeakPosts(_ posts: [Post]) {
        self.peakPosts = posts
        self.peakPostsTable.reloadData()
        if posts.count > 0 {
            peakNoPostsLabel.text = "\(posts.count) javnih objav"
        }
    }
    
    func didFetchingPeakPostsFailWithError(_ error: String) {
        print("Fetching peak data failed: \(error)")
        self.dismiss(animated: true)
    }
}

// MARK: - Peak Posts Table Data Source
extension PeakProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        peakPosts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeakPostCell", for: indexPath) as! PeakPostCell
        if peakPosts != nil && peakPosts?.count ?? 0 > 0 {
            if indexPath.row < peakPosts!.count {
                cell.configure(with: peakPosts![indexPath.row])
                return cell
            }
        }
        return cell
    }
}
