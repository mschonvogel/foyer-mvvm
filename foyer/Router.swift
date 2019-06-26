import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol RouterContract {
    func start(rootController: UITabBarController)
    func presentFeed()
    func presentStory(_ story: Story)
    func presentUser(_ userName: String)
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
        let vc = NavigationController(rootViewController: LoginViewController())
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
        pushOnCurrentViewControllerIfPossible(vc)
    }

    func presentUser(_ userName: String) {
        let vc = UserViewController(userName: userName)
        pushOnCurrentViewControllerIfPossible(vc)
    }

    func dismiss() {
        if let navigationController = tabBarViewController.presentedViewController as? UINavigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else if let presentedViewController = tabBarViewController.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        } else if let navigationController = tabBarViewController.selectedViewController as? UINavigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            tabBarViewController.dismiss(animated: true, completion: nil)
        }
    }

    private func pushOnCurrentViewControllerIfPossible(_ viewController: UIViewController) {
        if let navigationController = tabBarViewController.presentedViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if let presentedViewController = tabBarViewController.presentedViewController {
            presentedViewController.present(viewController, animated: true, completion: nil)
        } else if let navigationController = tabBarViewController.selectedViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            tabBarViewController.present(viewController, animated: true, completion: nil)
        }
    }
}

class NavigationController: UINavigationController {
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = viewController is HiddenTabBarViewController

        super.pushViewController(viewController, animated: animated)

        viewController.hidesBottomBarWhenPushed = false
    }
    override func popViewController(animated: Bool) -> UIViewController? {
        if viewControllers.count > 1 {
            viewControllers[viewControllers.count-2].hidesBottomBarWhenPushed = viewControllers[viewControllers.count-2] is HiddenTabBarViewController
        }

        return super.popViewController(animated: animated)
    }
}
