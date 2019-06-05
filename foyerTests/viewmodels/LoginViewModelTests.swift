import XCTest
import RxSwift
import RxTest
@testable import foyer

class LoginViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!

    private var routerSpy: RouterSpy!

    private let input_viewDidLoad = PublishSubject<Void>()
    private let input_emailTextChanged = PublishSubject<String?>()
    private let input_emailEditingDidEnd = PublishSubject<Void>()
    private let input_passwordTextChanged = PublishSubject<String?>()
    private let input_passwordEditingDidEnd = PublishSubject<Void>()
    private let input_submitButtonPressed = PublishSubject<Void>()
    private let input_cancelButtonPressed = PublishSubject<Void>()

    private let output_submitButtonEnabled = TestObserver<Bool>()
    private let output_cancelButtonEnabled = TestObserver<Bool>()
    private let output_emailInputBorderColor = TestObserver<UIColor>()
    private let output_passwordInputBorderColor = TestObserver<UIColor>()
    private let output_showActivityIndicator = TestObserver<Bool>()
    private let output_showErrorMessage = TestObserver<String>()

    override func setUp() {
        disposeBag = DisposeBag()
        routerSpy = RouterSpy()

        Environment.reset()
        Environment.shared.router = routerSpy

        let (submitButtonEnabled, cancelButtonEnabled, emailInputBorderColor,
            passwordInputBorderColor, showActivityIndicator, showErrorMessage) = loginViewModel(
            disposeBag: disposeBag,
            viewDidLoad: input_viewDidLoad,
            emailTextChanged: input_emailTextChanged,
            emailEditingDidEnd: input_emailEditingDidEnd,
            passwordTextChanged: input_passwordTextChanged,
            passwordEditingDidEnd: input_passwordEditingDidEnd,
            submitButtonPressed: input_submitButtonPressed,
            cancelButtonPressed: input_cancelButtonPressed
        )

        submitButtonEnabled
            .subscribe(output_submitButtonEnabled.observer)
            .disposed(by: disposeBag)
        cancelButtonEnabled
            .subscribe(output_cancelButtonEnabled.observer)
            .disposed(by: disposeBag)
        emailInputBorderColor
            .subscribe(output_emailInputBorderColor.observer)
            .disposed(by: disposeBag)
        passwordInputBorderColor
            .subscribe(output_passwordInputBorderColor.observer)
            .disposed(by: disposeBag)
        showActivityIndicator
            .subscribe(output_showActivityIndicator.observer)
            .disposed(by: disposeBag)
        showErrorMessage
            .subscribe(output_showErrorMessage.observer)
            .disposed(by: disposeBag)
    }

    func test_initialValues() {
        input_viewDidLoad.onNext(())
        output_submitButtonEnabled.assertValues([false])
        output_showActivityIndicator.assertValues([false])
        output_showErrorMessage.assertValues([])
    }

    func test_form_validation() {
        input_viewDidLoad.onNext(())

        input_emailTextChanged.onNext("malte")
        input_emailEditingDidEnd.onNext(())
        output_submitButtonEnabled.assertValues([false])
        output_emailInputBorderColor.assertValues([.red])

        input_passwordTextChanged.onNext("abc")
        input_passwordEditingDidEnd.onNext(())
        output_submitButtonEnabled.assertValues([false])
        output_passwordInputBorderColor.assertValues([.green])

        input_emailTextChanged.onNext("malte@bla")
        input_emailEditingDidEnd.onNext(())
        output_submitButtonEnabled.assertValues([false, true])
        output_emailInputBorderColor.assertValues([.red, .green])
    }

    func test_flow_success() {
        input_viewDidLoad.onNext(())

        input_emailTextChanged.onNext("test@tester.com")
        output_submitButtonEnabled.assertValues([false])

        input_passwordTextChanged.onNext("abc")
        output_submitButtonEnabled.assertValues([false, true])

        output_showActivityIndicator.assertValues([false])
        input_submitButtonPressed.onNext(())
        output_showActivityIndicator.assertValues([false, true, false])
        output_showErrorMessage.assertValues([])

        routerSpy.assertEquals(
            startCalled: [],
            presentLoginCalled: [],
            presentFeedCalled: [],
            presentStoryCalled: [],
            presentDiscoverCalled: [],
            presentProfileCalled: [],
            dismissCalled: [()]
        )
    }

    func test_flow_error() {
        Environment.shared.foyerClient.accountLogin = { (_, completion) in
            completion(
                .failure(.parsing)
            )
        }

        input_viewDidLoad.onNext(())

        input_emailTextChanged.onNext("test@tester.com")
        output_submitButtonEnabled.assertValues([false])

        input_passwordTextChanged.onNext("abc")
        output_submitButtonEnabled.assertValues([false, true])

        output_showActivityIndicator.assertValues([false])
        input_submitButtonPressed.onNext(())
        output_showActivityIndicator.assertValues([false, true, false])
        output_showErrorMessage.assertValues(["parsing error"])
    }

    func test_flow_cancel() {
        input_viewDidLoad.onNext(())

        output_cancelButtonEnabled.assertValues([true])

        input_cancelButtonPressed.onNext(())

        routerSpy.assertEquals(
            startCalled: [],
            presentLoginCalled: [],
            presentFeedCalled: [],
            presentStoryCalled: [],
            presentDiscoverCalled: [],
            presentProfileCalled: [],
            dismissCalled: [()]
        )
    }
}
