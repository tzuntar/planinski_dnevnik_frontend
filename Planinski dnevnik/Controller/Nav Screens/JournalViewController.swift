import UIKit

class JournalViewController : UIViewController {
    
    var journalLogic: JournalLogic?
    
    var posts: [Post]?
    
    @IBOutlet weak var postsTable: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTable.register(UINib(nibName: "JournalPostCell", bundle: nil),
                            forCellReuseIdentifier: "JournalPostCell")
        postsTable.dataSource = self    // see the extension below
        postsTable.delegate = self
        journalLogic = JournalLogic(delegatingActionsTo: self)
        
        // the pull-to-refresh thingy
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshJournal), for: .valueChanged)
        postsTable.refreshControl = refreshControl
        
        DispatchQueue.global(qos: .background).async {
            self.journalLogic!.retrievePosts()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowHikeEntryScreen" {
            guard let postsRow = sender as? Int else { return }
            let vc = segue.destination as! HikeEntryController
            vc.existingHike = posts![postsRow]
        }
    }

    @objc func refreshJournal() {
        DispatchQueue.global(qos: .background).async {
            self.journalLogic!.retrievePosts()
            DispatchQueue.main.async {
                self.postsTable.refreshControl?.endRefreshing()
            }
        }
    }
    
    @IBAction func navToFeedPressed() {
        // yes, it's technically its parent. yes, it's two levels higher in the hierarchy.
        if let parentVC = self.parent?.parent?.parent as? HomeSwipeController {
            parentVC.moveToPage(HomeSwipeController.PagesIndex.FeedPage.rawValue, animated: true)
        }
    }
}

// MARK: - Journal Delegate
extension JournalViewController: JournalDelegate {
    func didFetchPosts(_ posts: [Post]) {
        self.posts = posts
        noDataLabel.isHidden = posts.count > 0
        postsTable.reloadData()
    }
    
    func didFetchingFailWithError(_ error: any Error) {
        print("Warning: failed to fetch journal posts.")
    }
}

// MARK: - Posts Table View Data Source
extension JournalViewController: UITableViewDataSource {
    // vraca stevilo vrstic podatkov
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts?.count ?? 0    // posts.count ce ta ni nil, sicer 0
    }
    
    // napolni dano vrstico s podatki
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalPostCell", for: indexPath) as! JournalPostCell
        if posts != nil && posts?.count ?? 0 > 0 {
            if indexPath.row < posts!.count {
                cell.configure(with: posts![indexPath.row])
                return cell
            }
        }
        return cell
    }
}

// MAKR: - Posts Table View Delegate
extension JournalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            // delete item
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowHikeEntryScreen", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    /*func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }*/
}
