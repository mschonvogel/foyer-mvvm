import UIKit
import RxSwift

class ProfileHeaderView: UIView {
    private let disposeBag = DisposeBag()
    
    let user = PublishSubject<UserContract?>()
    let parentScrollViewContentOffset = PublishSubject<(contentOffset: CGPoint, viewSize: CGSize)>()

    private let container = UIStackView()
    private let topContainer = UIView()
    private let followersContainer = UIButton()
    private let followersCountView = UILabel()
    private let followersCountLabelView = UILabel()
    private let followingContainer = UIButton()
    private let followingCountView = UILabel()
    private let followingCountLabelView = UILabel()
    private let userPhotoView = UIImageView()
    private let nameView = UILabel()
    private let biographyTextView = UITextView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupBinding()
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBinding() {
        let (name, nameIsHidden, followersCount, followingCount, userPhoto, userPhotoScale, biography, biographyIsHidden) = profileHeaderViewModel(
            disposeBag: disposeBag,
            user: user,
            parentScrollViewContentOffset: parentScrollViewContentOffset,
            followersPressed: followersContainer.rx.tap.asObservable(),
            followingPressed: followingContainer.rx.tap.asObservable()
        )

        name
            .bind(to: nameView.rx.text)
            .disposed(by: disposeBag)
        nameIsHidden
            .bind(to: nameView.rx.isHidden)
            .disposed(by: disposeBag)
        followersCount
            .bind(to: followersCountView.rx.text)
            .disposed(by: disposeBag)
        followingCount
            .bind(to: followingCountView.rx.text)
            .disposed(by: disposeBag)
        userPhoto
            .bind(to: userPhotoView.rx.image)
            .disposed(by: disposeBag)
        userPhotoScale
            .bind { scale in
                self.userPhotoView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            .disposed(by: disposeBag)
        biography
            .bind(to: biographyTextView.rx.attributedText)
            .disposed(by: disposeBag)
        biographyIsHidden
            .bind(to: biographyTextView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        // View setup
        backgroundColor = .init(white: 0.95, alpha: 1)

        container.alignment = .fill
        container.axis = .vertical
        container.spacing = 5
        addSubview(container)

        container.addArrangedSubview(topContainer)

        topContainer.addSubview(followersContainer)

        followersCountView.font = .preferredFont(forTextStyle: .title1)
        centerStyle(followersCountView)
        followersContainer.addSubview(followersCountView)

        followersCountLabelView.text = "Followers"
        captionStyle(followersCountLabelView)
        centerStyle(followersCountLabelView)
        followersContainer.addSubview(followersCountLabelView)

        topContainer.addSubview(followingContainer)

        followingCountView.font = .preferredFont(forTextStyle: .title1)
        centerStyle(followingCountView)
        followingContainer.addSubview(followingCountView)

        followingCountLabelView.text = "Following"
        captionStyle(followingCountLabelView)
        centerStyle(followingCountLabelView)
        followingContainer.addSubview(followingCountLabelView)

        userPhotoView.layer.masksToBounds = true
        userPhotoView.layer.cornerRadius = 60
        userPhotoView.backgroundColor = .darkGray
        topContainer.addSubview(userPhotoView)

        nameView.font = .preferredFont(forTextStyle: .body)
        container.addArrangedSubview(nameView)

        bodyTextViewStyle(biographyTextView)
        container.addArrangedSubview(biographyTextView)
    }

    private func setupConstraints() {
        layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)

        container.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalTo(layoutMarginsGuide)
        }
        followersCountView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        followersCountLabelView.snp.makeConstraints {
            $0.top.equalTo(followersCountView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        followingCountView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        followingCountLabelView.snp.makeConstraints {
            $0.top.equalTo(followingCountView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        userPhotoView.snp.makeConstraints {
            $0.top.bottom.equalTo(topContainer)
            $0.centerX.equalTo(container)
            $0.width.height.equalTo(120)
        }
        followersContainer.snp.makeConstraints {
            $0.leading.equalTo(topContainer)
            $0.trailing.equalTo(userPhotoView.snp.leading)
            $0.centerY.equalTo(userPhotoView)
        }
        followingContainer.snp.makeConstraints {
            $0.centerY.equalTo(userPhotoView)
            $0.leading.equalTo(userPhotoView.snp.trailing)
            $0.trailing.equalTo(topContainer)
        }
        snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(container).offset(layoutMargins.top + layoutMargins.bottom)
        }
    }

    override class var requiresConstraintBasedLayout: Bool { return true }
}
