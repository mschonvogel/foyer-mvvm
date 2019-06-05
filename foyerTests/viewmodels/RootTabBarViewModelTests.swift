import XCTest
import RxSwift
import RxTest
@testable import foyer

class RootTabBarViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var routerSpy: RouterSpy!
    
    private let input_viewDidLoad = PublishSubject<Void>()
    private let input_tabBarItemPressed = PublishSubject<RootTabBarItem>()

    override func setUp() {
        disposeBag = DisposeBag()
        Environment.reset()
        routerSpy = RouterSpy()
        Environment.shared.router = routerSpy

        let () = rootTabBarViewModel(
            disposeBag: disposeBag,
            viewDidLoad: input_viewDidLoad,
            tabBarItemPressed: input_tabBarItemPressed
        )
    }

    func test_tabBarItemPressed_feed() {
        input_tabBarItemPressed.onNext(.feed)
        routerSpy.assertEquals(
            startCalled: [],
            presentLoginCalled: [],
            presentFeedCalled: [()],
            presentStoryCalled: [],
            presentDiscoverCalled: [],
            presentProfileCalled: [],
            dismissCalled: []
        )
    }

    func test_tabBarItemPressed_discover() {
        input_tabBarItemPressed.onNext(.discover)
        routerSpy.assertEquals(
            startCalled: [],
            presentLoginCalled: [],
            presentFeedCalled: [],
            presentStoryCalled: [],
            presentDiscoverCalled: [()],
            presentProfileCalled: [],
            dismissCalled: []
        )
    }

    func test_tabBarItemPressed_profile_notLoggedIn() {
        input_tabBarItemPressed.onNext(.profile)
        routerSpy.assertEquals(
            startCalled: [],
            presentLoginCalled: [()],
            presentFeedCalled: [],
            presentStoryCalled: [],
            presentDiscoverCalled: [],
            presentProfileCalled: [],
            dismissCalled: []
        )
    }

    func test_tabBarItemPressed_profile_loggedIn() {
        Environment.shared.user.onNext(.mock)
        input_tabBarItemPressed.onNext(.profile)
        routerSpy.assertEquals(
            startCalled: [],
            presentLoginCalled: [],
            presentFeedCalled: [],
            presentStoryCalled: [],
            presentDiscoverCalled: [],
            presentProfileCalled: [()],
            dismissCalled: []
        )
    }
}
