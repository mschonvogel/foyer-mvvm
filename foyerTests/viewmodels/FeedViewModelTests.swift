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

    func test_success() {
        input_viewDidLoad.onNext(())

        output_activitiesLoaded.assertValues([[Activity.mock]])
        output_showError.assertValues([])
    }

    func test_error() {
        Environment.shared.foyerClient.getFeatured = { completion in
            completion(
                .failure(.parsing)
            )
        }
        input_viewDidLoad.onNext(())

        output_activitiesLoaded.assertValues([])
        output_showError.assertValues(["parsing error"])
    }

    func test_reload() {
        output_reloadButtonEnabled.assertValues([true])
        output_activitiesLoaded.assertValues([])
        output_showError.assertValues([])

        input_viewDidLoad.onNext(())

        output_reloadButtonEnabled.assertValues([true, false, true])
        output_activitiesLoaded.assertValues([[Activity.mock]])
        output_showError.assertValues([])

        input_reloadButtonPressed.onNext(())

        output_activitiesLoaded.assertValues([[Activity.mock], [Activity.mock]])
        output_showError.assertValues([])
    }

    func test_itemSelected() {
        input_viewDidLoad.onNext(())
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
