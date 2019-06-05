import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol RouterContract {
    func start(rootController: UITabBarController)
    func presentFeed()
    func presentStory(_ story: Story)
    func presentDiscover()
    func presentProfile()
    func presentLogin()
    func dismiss()
}

class Router {
    private var tabBarViewController: UITabBarController!
}

extension Router: RouterContract {
    func start(rootController: UITabBarController) {
        self.tabBarViewController = rootController
    }

    func presentLogin() {
        let vc = UINavigationController(rootViewController: LoginViewController())
        tabBarViewController.present(vc, animated: true, completion: nil)
    }

    func presentFeed() {
        tabBarViewController.selectedIndex = RootTabBarItem.feed.rawValue
    }

    func presentDiscover() {
        tabBarViewController.selectedIndex = RootTabBarItem.discover.rawValue
    }

    func presentProfile() {
        tabBarViewController.selectedIndex = RootTabBarItem.profile.rawValue
    }

    func presentStory(_ story: Story) {
        let vc = StoryViewController(story: story)
        tabBarViewController.present(vc, animated: true, completion: nil)
    }

    func dismiss() {
        tabBarViewController.dismiss(animated: true, completion: nil)
    }
}
