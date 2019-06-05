import UIKit
import RxSwift

class DiscoverViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let buttonSubmit = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue

        buttonSubmit.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        buttonSubmit.setTitle("Submit", for: .normal)
        buttonSubmit.setTitleColor(.white, for: .normal)
        view.addSubview(buttonSubmit)

        buttonSubmit.snp.makeConstraints {
            $0.centerY.centerX.equalTo(view)
        }
    }

    @objc func buttonTapped() {
        Environment.shared.router.presentProfile()
    }
}
