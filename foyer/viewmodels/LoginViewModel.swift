import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxOptional

func loginViewModel(
    disposeBag: DisposeBag,
    viewDidLoad: Observable<Void>,
    emailTextChanged: Observable<String?>,
    emailEditingDidEnd: Observable<Void>,
    passwordTextChanged: Observable<String?>,
    passwordEditingDidEnd: Observable<Void>,
    submitButtonPressed: Observable<Void>,
    cancelButtonPressed: Observable<Void>
    ) -> (
    submitButtonEnabled: Observable<Bool>,
    cancelButtonEnabled: Observable<Bool>,
    emailInputBorderColor: Observable<UIColor>,
    passwordInputBorderColor: Observable<UIColor>,
    showActivityIndicator: Observable<Bool>,
    showErrorMessage: Observable<String>
    ) {
        let showErrorMessage: PublishSubject<String> = .init()
        let isLoading: BehaviorSubject<Bool> = .init(value: false)
        let isEmailValid: Observable<Bool> = emailTextChanged.map(Validator.isEmailValid)
        let isPasswordValid: Observable<Bool> = passwordTextChanged.map(Validator.isPasswordValid)
        let isFormValid: Observable<Bool> = .combineLatest(isEmailValid, isPasswordValid) { (isEmailValid, isPasswordValid) in isEmailValid && isPasswordValid }
        let submitButtonEnabled = Observable<Bool>
            .merge(
                viewDidLoad.mapConst(false),
                .combineLatest(isLoading, isFormValid) { (isLoading, isFormValid) in !isLoading && isFormValid }
            )
            .distinctUntilChanged()
        let cancelButtonEnabled = isLoading.map { !$0 }

        let emailInputBorderColor: Observable<UIColor> = Observable<Bool>
            .merge(
                emailEditingDidEnd.withLatestFrom(isEmailValid),
                isEmailValid.skipUntil(emailEditingDidEnd)
            )
            .distinctUntilChanged()
            .map { $0 ? .green : .red }

        let passwordInputBorderColor: Observable<UIColor> = Observable<Bool>
            .merge(
                passwordEditingDidEnd.withLatestFrom(isPasswordValid),
                isPasswordValid.skipUntil(passwordEditingDidEnd)
            )
            .distinctUntilChanged()
            .map { $0 ? .green : .red }

        submitButtonPressed
            .withLatestFrom(
                Observable<LoginRequestPayload>.combineLatest(
                    emailTextChanged.filterNil(),
                    passwordTextChanged.filterNil(),
                    resultSelector: { (email, password) in LoginRequestPayload(email: email, password: password) }
                )
            )
            .bind { payload in
                isLoading.onNext(true)
                Environment.shared.foyerClient.accountLogin(payload) { result in
                    switch result {
                    case .success:
                        Environment.shared.router.dismiss()
                    case .failure(let error):
                        showErrorMessage.onNext(error.localizedDescription)
                    }
                    isLoading.onNext(false)
                }
            }
            .disposed(by: disposeBag)
        cancelButtonPressed
            .bind { Environment.shared.router.dismiss() }
            .disposed(by: disposeBag)

        return (
            submitButtonEnabled: submitButtonEnabled,
            cancelButtonEnabled: cancelButtonEnabled,
            emailInputBorderColor: emailInputBorderColor,
            passwordInputBorderColor: passwordInputBorderColor,
            showActivityIndicator: isLoading,
            showErrorMessage: showErrorMessage
        )
}
