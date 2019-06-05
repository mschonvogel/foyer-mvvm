import UIKit
import RxSwift

enum RootTabBarItem: Int, CaseIterable {
    case feed = 0
    case discover
    case profile
}

extension RootTabBarItem {
    init?(viewController: UIViewController) {
        var vc = viewController
        if let nc = vc as? UINavigationController {
            vc = nc.viewControllers.last!
        }

        switch vc {
        case is FeedViewController:
            self = .feed
        case is DiscoverViewController:
            self = .discover
        case is AppUserViewController:
            self = .profile
        default:
            return nil
        }
    }
}

class RootTabBarViewController: UITabBarController {
    private let disposeBag = DisposeBag()
    private let tabBarItemPressed = PublishSubject<RootTabBarItem>()

    private let feedViewController = FeedViewController()
    private let feedNavigationController: UINavigationController
    private let discoverViewController = DiscoverViewController()
    private let discoverNavigationController: UINavigationController
    private let profileViewController = AppUserViewController()
    private let profileNavigationController: UINavigationController

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        feedNavigationController = .init(rootViewController: feedViewController)
        discoverNavigationController = .init(rootViewController: discoverViewController)
        profileNavigationController = .init(rootViewController: profileViewController)

        super.init(nibName: nil, bundle: nil)

        delegate = self
        viewControllers = RootTabBarItem.allCases.map {
            switch $0 {
            case .feed:
                return feedNavigationController
            case .discover:
                return discoverNavigationController
            case .profile:
                return profileNavigationController
            }
        }

        feedNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 1)
        discoverNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 2)
        profileNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 3)

        rootTabBarViewModel(
            disposeBag: disposeBag,
            viewDidLoad: rx.viewDidLoad.asObservable(),
            tabBarItemPressed: tabBarItemPressed
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RootTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let tabBarItem = RootTabBarItem(viewController: viewController) {
            tabBarItemPressed.onNext(tabBarItem)
        }
        return false
    }
}
