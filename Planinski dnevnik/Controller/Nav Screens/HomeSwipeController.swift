// Handles swipe left-right to navigate between screens
import UIKit

class HomeSwipeController: EZSwipeController {

    override func setupView() {
        super.setupView()
        navigationBarShouldNotExist = true
        datasource = self
    }

    enum PagesIndex: Int {
        case LogPage = 0
        case FeedPage = 1
        case ProfilePage = 2
    }

}

extension HomeSwipeController: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let logVC = storyboard.instantiateViewController(withIdentifier: "log-vc")
        let feedVC = storyboard.instantiateViewController(identifier: "feed-vc")
        let profileVC = storyboard.instantiateViewController(identifier: "profile-vc")

        return [logVC, feedVC, profileVC]
    }

    func indexOfStartingPage() -> Int { 1 }
}
