import UIKit
import SnapKit
import RxSwift
import RxCocoa

class StorySectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "StorySectionHeaderView"

    private var disposeBag: DisposeBag!

    private let containerStackView = UIStackView()
    private let titleTextView = UITextView()
    private let contentTextView = UITextView()
    private let buttonStackView = UIStackView()

    private let upButton = UIButton()
    private let downButton = UIButton()
    private let deleteButton = UIButton()
    private let addButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layoutMargins = .init(top: 0, left: 10, bottom: 10, right: 10)

        upButton.backgroundColor = .red
        buttonStackView.addArrangedSubview(upButton)
        downButton.backgroundColor = .blue
        buttonStackView.addArrangedSubview(downButton)

        let space = UIView()
        buttonStackView.addArrangedSubview(space)
        space.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(50000)
        }

        deleteButton.backgroundColor = .yellow
        buttonStackView.addArrangedSubview(deleteButton)
        addButton.backgroundColor = .green
        buttonStackView.addArrangedSubview(addButton)
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fill
        buttonStackView.spacing = 5

        containerStackView.addArrangedSubview(buttonStackView)

        storySectionHeaderTitleTextViewStyle(titleTextView)
        containerStackView.addArrangedSubview(titleTextView)
        
        storySectionHeaderContentTextViewStyle(contentTextView)
        containerStackView.addArrangedSubview(contentTextView)

        containerStackView.alignment = .fill
        containerStackView.axis = .vertical
        containerStackView.spacing = 5
        addSubview(containerStackView)

        containerStackView.snp.makeConstraints {
            $0.topMargin.leadingMargin.trailingMargin.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with value: Story.Section, isEditing: BehaviorRelay<Bool>) {
        disposeBag = DisposeBag()

        let (title, titleIsHidden, titleBackgroundColor, titleTextContainerInsets, content, contentIsHidden, contentBackgroundColor, contentTextContainerInsets) = storySectionHeaderViewModel(disposeBag: disposeBag, isEditing: isEditing, section: .of(value))

        title
            .bind(to: titleTextView.rx.attributedText)
            .disposed(by: disposeBag)
        titleIsHidden
            .bind(to: titleTextView.rx.isHidden)
            .disposed(by: disposeBag)
        titleBackgroundColor
            .bind(to: titleTextView.rx.backgroundColor)
            .disposed(by: disposeBag)
        titleTextContainerInsets
            .bind { [weak self] in self?.titleTextView.textContainerInset = $0 }
            .disposed(by: disposeBag)
        content
            .bind(to: contentTextView.rx.attributedText)
            .disposed(by: disposeBag)
        contentIsHidden
            .bind(to: contentTextView.rx.isHidden)
            .disposed(by: disposeBag)
        contentBackgroundColor
            .bind(to: contentTextView.rx.backgroundColor)
            .disposed(by: disposeBag)
        contentTextContainerInsets
            .bind { [weak self] in self?.contentTextView.textContainerInset = $0 }
            .disposed(by: disposeBag)
    }

    class func calculateSize(viewWidth width: CGFloat, section: Story.Section, isEditing: Bool) -> CGSize {
        let availableWidth = width - 20 - (isEditing ? 8 : 0)
        let buttonStackViewHeight: CGFloat = 34

        var height: CGFloat = 0

        if isEditing {
            height += buttonStackViewHeight
            height += 5
        }

        if let title = section.title ?? (isEditing ? " " : nil) {
            let titleString = NSAttributedString(string: title, attributes: storySectionHeaderTitleAttributes)
            let titleHeight = titleString.sizeFittingWidth(availableWidth).height
            height += titleHeight
            height += 5
            height += isEditing ? 8 : 0
        }

        if let text = section.text ?? (isEditing ? " " : nil) {
            let textString = NSAttributedString(string: text, attributes: storySectionHeaderContentAttributes)
            let textHeight = textString.sizeFittingWidth(availableWidth).height
            height += textHeight
            height += 10
            height += isEditing ? 8 : 0
        }

        return .init(width: width, height: height)
    }
}
