import UIKit
import RxSwift
import RxCocoa

class StoryItemCellView: UICollectionViewCell {
    static let reuseIdentifier = "StoryItemCellView"

    private let imageView: UIImageView
    private var disposeBag: DisposeBag!

    override init(frame: CGRect) {
        imageView = UIImageView(frame: CGRect(origin: .zero, size: frame.size))

        super.init(frame: frame)

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.backgroundColor = .groupTableViewBackground
        contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with value: Story.Item) {
        disposeBag = DisposeBag()

        let (image) = storyItemCellViewModel(
            disposeBag: disposeBag,
            item: .of(value)
        )

        image
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}
