import UIKit

class FeedViewController: UIViewController {
    
    var feedLogic: FeedLogic?
    
    var posts: [Post]?

    @IBOutlet weak var postsTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        postsTable.register(UINib(nibName: "FeedPostCell", bundle: nil),
                            forCellReuseIdentifier: "FeedPostCell")
        postsTable.dataSource = self    // refers to the extension below
        feedLogic = FeedLogic(delegatingActionsTo: self)
        
        // the pull-to-refresh thingy
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        postsTable.refreshControl = refreshControl
        
        DispatchQueue.global(qos: .background).async {  // tko se gre v background thread
            self.feedLogic!.retrievePosts()             // npr. ko rabis kake API requeste itd.
            // ker smo v background threadu bo karksnkol UI klic kle failu!
            // rabimo prvo it nazaj v main thread s DispatchQueue.main.async { main thread koda }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowUserProfile",
              let userId = sender as? Int,
              let destination = segue.destination as? UserProfileController
        else { return }
        destination.userId = userId
    }
    
    @objc func refreshFeed() {
        DispatchQueue.global(qos: .background).async {  // gremo v background thread za API request
            self.feedLogic!.retrievePosts()
            DispatchQueue.main.async {  // gremo nazaj na main thread za VSE ui stvari
                self.postsTable.refreshControl?.endRefreshing()
            }
        }
    }
    
    @IBAction func navToLogPressed() {
        // yes, it's technically its parent. yes, it's two levels higher in the hierarchy.
        if let parentVC = self.parent?.parent?.parent as? HomeSwipeController {
            parentVC.moveToPage(HomeSwipeController.PagesIndex.LogPage.rawValue, animated: true)
        }
    }

    @IBAction func navToProfilePressed() {
        if let parentVC = self.parent?.parent?.parent as? HomeSwipeController {
            parentVC.moveToPage(HomeSwipeController.PagesIndex.ProfilePage.rawValue, animated: true)
        }
    }
}

// MARK: - Feed Delegate
extension FeedViewController: FeedDelegate {
    func didFetchPosts(_ posts: [Post]) {
        self.posts = posts
        postsTable.reloadData()
    }
    
    func didFetchingFailWithError(_ error: any Error) {
        print("Warning: failed to fetch feed posts.")
    }
}

// MARK: - Posts Table View Data Source
extension FeedViewController: UITableViewDataSource {
    // vraca stevilo vrstic podatkov
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts?.count ?? 0    // posts.count ce ta ni nil, sicer 0
    }
    
    // napolni dano vrstico s podatki
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedPostCell", for: indexPath) as! FeedPostCell
        cell.delegate = self
        if posts != nil && posts?.count ?? 0 > 0 {
            if indexPath.row < posts!.count {
                cell.configure(with: posts![indexPath.row])
                return cell
            }
        }
        return cell
    }
}

// MARK: - Posts Table Cell Delegate
extension FeedViewController: FeedPostCellDelegate {
    func feedPostCell(_ cell: FeedPostCell, didTapUserWithId id: Int) {
        self.performSegue(withIdentifier: "ShowUserProfile", sender: id)
        // invokes the prepare(for: segue...) method above
    }
}
