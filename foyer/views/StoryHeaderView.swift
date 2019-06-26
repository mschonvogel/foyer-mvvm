import UIKit
import RxSwift
import RxCocoa
import SnapKit

class StoryHeaderView: UIView {
    let story = PublishSubject<Story>()

    private let disposeBag = DisposeBag()
    private let imageView = UIImageView()
    private let titleTextView = UITextView()
    private let authorNameButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupBinding()
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupBinding()
        setupViews()
        setupConstraints()
    }

    func setupBinding() {
        let (title, authorName, coverImage) = storyHeaderViewModel(
            disposeBag: disposeBag,
            story: story,
            authorNameButtonPressed: authorNameButton.rx.tap.asObservable()
        )

        title
            .bind(to: titleTextView.rx.text)
            .disposed(by: disposeBag)
        authorName
            .bind(to: authorNameButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        coverImage
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }

    func setupViews() {
        backgroundColor = .magenta

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)

        storyHeaderTextViewStyle(titleTextView)
        addSubview(titleTextView)

        authorNameButton.setTitleColor(.blue, for: .normal)
        addSubview(authorNameButton)
    }

    func setupConstraints() {
        layoutMargins = .init(top: 25, left: 25, bottom: 25, right: 25)

        imageView.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleTextView.snp.makeConstraints {
            $0.leadingMargin.trailingMargin.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        authorNameButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualToSuperview().inset(20)
            $0.bottomMargin.equalToSuperview()
        }
    }
}
