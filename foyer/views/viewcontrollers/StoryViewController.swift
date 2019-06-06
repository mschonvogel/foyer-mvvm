import Foundation
import UIKit
import RxSwift

final class StoryViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let closeButton = UIButton(type: .infoDark)
    private let titleLabel = UILabel()
    private let authorNameButton = UIButton()

    init(story: Story) {
        super.init(nibName: nil, bundle: nil)

        let (title, authorName, _) = storyViewModel(
            disposeBag: disposeBag,
            viewDidLoad: rx.viewDidLoad.asObservable(),
            story: .of(story),
            authorNameButtonPressed: authorNameButton.rx.tap.asObservable(),
            closeButtonPressed: closeButton.rx.tap.asObservable()
        )

        title
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        authorName
            .bind(to: authorNameButton.rx.title())
            .disposed(by: disposeBag)

        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        view.addSubview(closeButton)

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)

        authorNameButton.setTitleColor(.blue, for: .normal)
        view.addSubview(authorNameButton)

        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view).inset(20)
            $0.centerY.equalTo(view)
        }
        authorNameButton.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.width.lessThanOrEqualTo(view).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
