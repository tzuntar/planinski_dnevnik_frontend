import UIKit

class LogViewController : UIViewController {
    
    var journalLogic: JournalLogic?
    
    var posts: [Post]?
    
    @IBOutlet weak var postsTable: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTable.register(UINib(nibName: "JournalPostCell", bundle: nil),
                            forCellReuseIdentifier: "JournalPostCell")
        postsTable.dataSource = self    // see the extension below
        journalLogic = JournalLogic(delegatingActionsTo: self)
        
        // the pull-to-refresh thingy
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshJournal), for: .valueChanged)
        postsTable.refreshControl = refreshControl
        
        DispatchQueue.global(qos: .background).async {
            self.journalLogic!.retrievePosts()
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
extension LogViewController: JournalDelegate {
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
extension LogViewController: UITableViewDataSource {
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
