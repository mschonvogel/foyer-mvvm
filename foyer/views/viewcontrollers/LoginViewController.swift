import UIKit
import RxSwift

class LoginViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let scrollView = UIScrollView()
    private let titleLabel = UILabel()
    private let formContainer = UIStackView()
    private let emailLabel = UILabel()
    private let emailInput = UITextField()
    private let passwordLabel = UILabel()
    private let passwordInput = UITextField()
    private let submitButton = UIButton()
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    private let activityIndicator = UIActivityIndicatorView(style: .gray)

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        let (
        submitButtonEnabled, cancelButtonEnabled, emailInputBorderColor, passwordInputBorderColor, showActivityIndicator, showErrorMessage
            ) = loginViewModel(
                disposeBag: disposeBag,
                viewDidLoad: rx.viewDidLoad.asObservable(),
                emailTextChanged: emailInput.rx.value.asObservable(),
                emailEditingDidEnd: emailInput.rx.controlEvent(.editingDidEnd).asObservable(),
                passwordTextChanged: passwordInput.rx.value.asObservable(),
                passwordEditingDidEnd: passwordInput.rx.controlEvent(.editingDidEnd).asObservable(),
                submitButtonPressed: submitButton.rx.tap.asObservable(),
                cancelButtonPressed: cancelButton.rx.tap.asObservable()
        )

        submitButtonEnabled
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)
        cancelButtonEnabled
            .bind(to: cancelButton.rx.isEnabled)
            .disposed(by: disposeBag)
        emailInputBorderColor
            .bind(to: emailInput.rx.backgroundColor)
            .disposed(by: disposeBag)
        passwordInputBorderColor
            .bind(to: passwordInput.rx.backgroundColor)
            .disposed(by: disposeBag)
        showActivityIndicator
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        showErrorMessage
            .bind { [weak self] message in
                self?.displayMessage(message)
            }
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        view.backgroundColor = .white

        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        formContainer.alignment = .fill
        formContainer.axis = .vertical
        formContainer.spacing = 5
        scrollView.addSubview(formContainer)

        emailLabel.text = "Email address"
        emailLabel.font = .preferredFont(forTextStyle: .caption1)
        emailLabel.numberOfLines = 0
        formContainer.addArrangedSubview(emailLabel)

        emailInput.placeholder = "Email address"
        emailInput.font = .preferredFont(forTextStyle: .body)
        emailInput.keyboardType = .emailAddress
        emailInput.autocorrectionType = .no
        emailInput.autocapitalizationType = .none
        emailInput.backgroundColor = .groupTableViewBackground
        formContainer.addArrangedSubview(emailInput)

        passwordLabel.text = "Password"
        passwordLabel.font = .preferredFont(forTextStyle: .caption1)
        passwordLabel.numberOfLines = 0
        formContainer.addArrangedSubview(passwordLabel)

        passwordInput.placeholder = "Password"
        passwordInput.font = .preferredFont(forTextStyle: .body)
        passwordInput.backgroundColor = .groupTableViewBackground
        passwordInput.isSecureTextEntry = true
        formContainer.addArrangedSubview(passwordInput)

        submitButton.setTitle("Login", for: .normal)
        submitButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        submitButton.setBackgroundImage(UIImage(color: .blue), for: .normal)
        submitButton.setBackgroundImage(UIImage(color: .lightGray), for: .disabled)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.masksToBounds = true
        submitButton.layer.cornerRadius = 5
        formContainer.addArrangedSubview(submitButton)

        // Constraints
        formContainer.setCustomSpacing(10, after: emailInput)
        formContainer.setCustomSpacing(15, after: passwordInput)

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        formContainer.snp.makeConstraints {
            $0.top.equalTo(scrollView).inset(20)
            $0.bottom.centerX.equalTo(scrollView)
            $0.width.lessThanOrEqualTo(600).priority(.high)
            $0.width.equalTo(scrollView).inset(20).priority(.high)
        }
        emailInput.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        passwordInput.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        submitButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }
}
