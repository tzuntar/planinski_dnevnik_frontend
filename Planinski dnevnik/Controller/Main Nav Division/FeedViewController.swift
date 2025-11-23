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
    
    @objc func refreshFeed() {
        DispatchQueue.global(qos: .background).async {  // gremo v background thread za API request
            self.feedLogic!.retrievePosts()
            DispatchQueue.main.async {  // gremo nazaj na main thread za VSE ui stvari
                self.postsTable.refreshControl?.endRefreshing()
            }
        }
    }
    
}

// MARK: - Feed Delegate
extension FeedViewController: FeedDelegate {
    func didFetchPosts(_ posts: [Post]) {
        self.posts = posts
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
        if posts != nil && posts?.count ?? 0 > 0 {
            if indexPath.row < posts!.count {
                cell.loadPost(posts![indexPath.row])
                return cell
            }
        }
        return cell
    }
}
