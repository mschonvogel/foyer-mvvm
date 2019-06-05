import UIKit
import RxSwift
import RxCocoa

class FeedCellView: UICollectionViewCell {
    static let reuseIdentifier = "FeedCellView"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    private let disposeBag = DisposeBag()

    let story = PublishSubject<Story>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .white

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)

        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        contentView.addSubview(titleLabel)

        imageView.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
        titleLabel.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }

        let (title, _, coverImage) = feedCellViewModel(
            disposeBag: disposeBag,
            story: story,
            prepareForReuse: prepareForReuseProperty
        )

        coverImage
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        title
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let prepareForReuseProperty = PublishSubject<Void>()
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareForReuseProperty.onNext(())
    }
}
