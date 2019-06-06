import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol RouterContract {
    func start(rootController: UITabBarController)
    func presentFeed()
    func presentStory(_ story: Story)
    func presentUser(_ user: UserContract)
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
        pushOnCurrentViewControllerIfPossible(vc)
    }

    func presentUser(_ user: UserContract) {
        let vc = AppUserViewController()
        pushOnCurrentViewControllerIfPossible(vc)
    }

    func dismiss() {
        if let navigationController = tabBarViewController.presentedViewController as? UINavigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
            return
        }
        if let presentedViewController = tabBarViewController.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
            return
        }
        if let navigationController = tabBarViewController.selectedViewController as? UINavigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
            return
        }
        tabBarViewController.dismiss(animated: true, completion: nil)
    }

    private func pushOnCurrentViewControllerIfPossible(_ viewController: UIViewController) {
        if let navigationController = tabBarViewController.presentedViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
            return
        }
        if let presentedViewController = tabBarViewController.presentedViewController {
            presentedViewController.present(viewController, animated: true, completion: nil)
            return
        }
        if let navigationController = tabBarViewController.selectedViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
            return
        }
        tabBarViewController.present(viewController, animated: true, completion: nil)
    }
}
