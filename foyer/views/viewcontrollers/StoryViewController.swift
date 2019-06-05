import Foundation
import UIKit
import RxSwift

final class StoryViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let closeButton = UIButton(type: .infoDark)
    private let titleLabel = UILabel()

    init(story: Story) {
        super.init(nibName: nil, bundle: nil)

        let (title, _) = storyViewModel(
            disposeBag: disposeBag,
            viewDidLoad: rx.viewDidLoad.asObservable(),
            story: .of(story),
            closeButtonPressed: closeButton.rx.tap.asObservable()
        )

        title
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
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

        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view).inset(20)
            $0.centerY.equalTo(view)
        }
    }
}
