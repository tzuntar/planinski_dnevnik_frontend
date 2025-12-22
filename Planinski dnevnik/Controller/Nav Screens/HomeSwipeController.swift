// Handles swipe left-right to navigate between screens
import UIKit

class HomeSwipeController: EZSwipeTabController {

    override func setupView() {
        super.setupView()
        datasource = self
    }

    enum PagesIndex: Int {
        case LogPage = 0
        case FeedPage = 1
        case ProfilePage = 2
    }

}

extension HomeSwipeController: EZSwipeTabControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let logVC = storyboard.instantiateViewController(withIdentifier: "log-vc")
        let feedVC = storyboard.instantiateViewController(identifier: "feed-vc")
        let profileVC = storyboard.instantiateViewController(identifier: "profile-vc")

        return [logVC, feedVC, profileVC]
    }
    
    func tabItemsData() -> [EZSwipeTabItem] {
        return [
            // sistemske SF Symbols ikonce
            EZSwipeTabItem(systemIconName: "book", title: "Moji vzponi"),
            EZSwipeTabItem(systemIconName: "house", title: "Domača stran"),
            EZSwipeTabItem(systemIconName: "person", title: "Moj profil")
        ]
    }
    
    func indexOfStartingPage() -> Int { 1 }
}
