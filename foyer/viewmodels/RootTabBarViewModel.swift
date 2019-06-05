import Foundation
import RxSwift

func rootTabBarViewModel(
    disposeBag: DisposeBag,
    viewDidLoad: Observable<Void>,
    tabBarItemPressed: Observable<RootTabBarItem>
    ) -> (
    ) {
        tabBarItemPressed
            .withLatestFrom(Environment.shared.user) { (tabBarItem, user) in (tabBarItem, user) }
            .bind { (tabBarItem, user) in
                switch (tabBarItem, user) {
                case (.feed, _):
                    Environment.shared.router.presentFeed()
                case (.discover, _):
                    Environment.shared.router.presentDiscover()
                case (.profile, nil):
                    Environment.shared.router.presentLogin()
                case (.profile, _):
                    Environment.shared.router.presentProfile()
                }
            }
            .disposed(by: disposeBag)

        return ()
}
