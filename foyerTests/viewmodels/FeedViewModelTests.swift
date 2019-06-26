import XCTest
import RxSwift
import RxTest
@testable import foyer

class FeedViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!

    private var routerSpy: RouterSpy!

    private let input_viewDidLoad = PublishSubject<Void>()
    private let input_reloadButtonPressed = PublishSubject<Void>()
    private let input_itemSelected = PublishSubject<IndexPath>()

    private let output_activitiesLoaded = TestObserver<[Activity]>()
    private let output_showError = TestObserver<String>()
    private let output_reloadButtonEnabled = TestObserver<Bool>()

    override func setUp() {
        Environment.reset()
        disposeBag = DisposeBag()
        routerSpy = RouterSpy()
        Environment.shared.router = routerSpy

        let (activitiesLoaded, showError, reloadButtonEnabled) = feedViewModel(
            disposeBag: disposeBag,
            viewDidLoad: input_viewDidLoad,
            itemSelected: input_itemSelected,
            reloadButtonPressed: input_reloadButtonPressed
        )

        activitiesLoaded
            .subscribe(output_activitiesLoaded.observer)
            .disposed(by: disposeBag)
        showError
            .subscribe(output_showError.observer)
            .disposed(by: disposeBag)
        reloadButtonEnabled
            .subscribe(output_reloadButtonEnabled.observer)
            .disposed(by: disposeBag)
    }

    func test_success_loggedIn() {
        let exp = expectation(description: "test_success_loggedIn")
        Environment.shared.user.onNext(.mock)
        Environment.shared.foyerClient.getFeed = { (page, completion) in
            completion(
                .success([Activity.mock])
            )
            exp.fulfill()
        }

        input_viewDidLoad.onNext(())

        waitForExpectations(timeout: 0.5)

        output_activitiesLoaded.assertValues([[Activity.mock]])
        output_showError.assertValues([])
    }

    func test_success_loggedOut() {
        let exp = expectation(description: "test_success_loggedOut")
        Environment.shared.user.onNext(nil)
        Environment.shared.foyerClient.getFeatured = { completion in
            completion(
                .success([Story.mock])
            )
            exp.fulfill()
        }

        input_viewDidLoad.onNext(())

        waitForExpectations(timeout: 0.5)

        output_activitiesLoaded.assertValues([[Activity.mock]])
        output_showError.assertValues([])
    }

    func test_error() {
        let exp = expectation(description: "test_error")
        Environment.shared.user.onNext(nil)
        Environment.shared.foyerClient.getFeatured = { completion in
            completion(
                .failure(.parsing)
            )
            exp.fulfill()
        }
        input_viewDidLoad.onNext(())

        waitForExpectations(timeout: 0.5)

        output_activitiesLoaded.assertValues([])
        output_showError.assertValues(["parsing error"])
    }

    func test_reload() {
        let exp1 = expectation(description: "test_reload1")
        Environment.shared.user.onNext(nil)
        Environment.shared.foyerClient.getFeatured = { completion in
            completion(
                .success([Story.mock])
            )
            exp1.fulfill()
        }

        output_reloadButtonEnabled.assertValues([true])
        output_activitiesLoaded.assertValues([])
        output_showError.assertValues([])

        input_viewDidLoad.onNext(())

        wait(for: [exp1], timeout: 0.6)

        output_reloadButtonEnabled.assertValues([true, false, true])
        output_activitiesLoaded.assertValues([[Activity.mock]])
        output_showError.assertValues([])

        let exp2 = expectation(description: "test_reload2")
        Environment.shared.user.onNext(nil)
        Environment.shared.foyerClient.getFeatured = { completion in
            completion(
                .success([Story.mock])
            )
            exp2.fulfill()
        }

        input_reloadButtonPressed.onNext(())

        wait(for: [exp2], timeout: 0.6)

        output_activitiesLoaded.assertValues([[Activity.mock], [Activity.mock]])
        output_showError.assertValues([])
    }

    func test_itemSelected() {
        let exp = expectation(description: "test_itemSelected")
        Environment.shared.user.onNext(nil)
        Environment.shared.foyerClient.getFeatured = { completion in
            completion(
                .success([Story.mock])
            )
            exp.fulfill()
        }

        input_viewDidLoad.onNext(())

        waitForExpectations(timeout: 0.6)

        input_itemSelected.onNext(IndexPath(item: 0, section: 0))

        routerSpy.assertEquals(
            startCalled: [],
            presentLoginCalled: [],
            presentFeedCalled: [],
            presentStoryCalled: [.mock],
            presentDiscoverCalled: [],
            presentProfileCalled: [],
            dismissCalled: []
        )
    }
}
