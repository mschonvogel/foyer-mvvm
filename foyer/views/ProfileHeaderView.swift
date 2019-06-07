import UIKit
import RxSwift

class ProfileHeaderView: UIView {
    private let disposeBag = DisposeBag()
    
    let user = PublishSubject<UserContract?>()
    let parentScrollViewContentOffset = PublishSubject<(contentOffset: CGPoint, viewSize: CGSize)>()

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

        // Binding
        let (name, followersCount, followingCount, userPhoto, userPhotoScale, biography) = profileHeaderViewModel(
            disposeBag: disposeBag,
            user: user,
            parentScrollViewContentOffset: parentScrollViewContentOffset,
            followersPressed: followersContainer.rx.tap.asObservable(),
            followingPressed: followingContainer.rx.tap.asObservable()
        )

        name
            .bind(to: nameView.rx.text)
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

        // View setup
        backgroundColor = .init(white: 0.95, alpha: 1)

        addSubview(followersContainer)

        followersCountView.font = .preferredFont(forTextStyle: .title1)
        followersCountView.textAlignment = .center
        followersContainer.addSubview(followersCountView)

        followersCountLabelView.text = "Followers"
        followersCountLabelView.textAlignment = .center
        followersCountLabelView.textColor = .darkGray
        followersCountLabelView.font = .preferredFont(forTextStyle: .caption1)
        followersContainer.addSubview(followersCountLabelView)

        addSubview(followingContainer)

        followingCountView.font = .preferredFont(forTextStyle: .title1)
        followingCountView.textAlignment = .center
        followingContainer.addSubview(followingCountView)

        followingCountLabelView.text = "Following"
        followingCountLabelView.textAlignment = .center
        followingCountLabelView.textColor = .darkGray
        followingCountLabelView.font = .preferredFont(forTextStyle: .caption1)
        followingContainer.addSubview(followingCountLabelView)

        userPhotoView.layer.masksToBounds = true
        userPhotoView.layer.cornerRadius = 60
        userPhotoView.backgroundColor = .darkGray
        addSubview(userPhotoView)

        nameView.font = .preferredFont(forTextStyle: .body)
        addSubview(nameView)

        biographyTextView.textContainerInset = .zero
        biographyTextView.textContainer.lineFragmentPadding = 0
        biographyTextView.backgroundColor = .clear
        biographyTextView.isScrollEnabled = false
        biographyTextView.contentInset = .zero
        biographyTextView.isOpaque = false
        biographyTextView.isEditable = false
        biographyTextView.autocorrectionType = .no
        biographyTextView.autocapitalizationType = .none
        biographyTextView.dataDetectorTypes = [.link, .phoneNumber, .address]
        biographyTextView.isUserInteractionEnabled = true

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3

        biographyTextView.linkTextAttributes = [
            .paragraphStyle: style,
            .underlineStyle : 1,
            .foregroundColor: UIColor.blue
        ]
        addSubview(biographyTextView)

        // Constraints
        layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)

        let container = UILayoutGuide()
        addLayoutGuide(container)

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
            $0.top.equalTo(container).offset(10)
            $0.centerX.equalTo(container)
            $0.width.height.equalTo(120)
        }
        followersContainer.snp.makeConstraints {
            $0.leading.equalTo(container)
            $0.trailing.equalTo(userPhotoView.snp.leading)
            $0.centerY.equalTo(userPhotoView)
        }
        followingContainer.snp.makeConstraints {
            $0.centerY.equalTo(userPhotoView)
            $0.leading.equalTo(userPhotoView.snp.trailing)
            $0.trailing.equalTo(container)
        }
        nameView.snp.makeConstraints {
            $0.top.equalTo(userPhotoView.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(container)
        }
        biographyTextView.snp.makeConstraints {
            $0.top.equalTo(nameView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalTo(container)
        }
        snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(container).offset(layoutMargins.top + layoutMargins.bottom)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var requiresConstraintBasedLayout: Bool { return true }
}
