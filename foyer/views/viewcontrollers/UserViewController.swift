import UIKit
import RxSwift
import RxCocoa
import SnapKit

class UserViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let headerViewContainer = UIView()
    private let headerView = ProfileHeaderView()
    private let collectionView: UICollectionView
    private let collectionViewLayout = ParallaxFlowLayout()
    private var headerViewContainerHeightConstraint: NSLayoutConstraint?

    convenience init(userName: String) {
        self.init(nibName: nil, bundle: nil)

        let (user, stories, recalculateHeaderSize, _) = userViewModel(
            disposeBag: disposeBag,
            userName: .of(userName),
            viewDidLoad: rx.viewDidLoad.asObservable(),
            itemSelected: collectionView.rx.itemSelected.asObservable()
        )

        user
            .bind(to: headerView.user)
            .disposed(by: disposeBag)
        recalculateHeaderSize
            .bind { [weak self] _ in self?.updateHeaderSize() }
            .disposed(by: disposeBag)
        stories
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCellView.reuseIdentifier, cellType: FeedCellView.self)) { (_, story, cell) in
                cell.story.onNext(story)
            }
            .disposed(by: disposeBag)
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        let (user, stories, recalculateHeaderSize, _) = appUserViewModel(
            disposeBag: disposeBag,
            viewDidLoad: rx.viewDidLoad.asObservable(),
            itemSelected: collectionView.rx.itemSelected.asObservable()
        )

        user
            .bind(to: headerView.user)
            .disposed(by: disposeBag)
        recalculateHeaderSize
            .bind { [weak self] _ in self?.updateHeaderSize() }
            .disposed(by: disposeBag)
        stories
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCellView.reuseIdentifier, cellType: FeedCellView.self)) { (_, story, cell) in
                cell.story.onNext(story)
            }
            .disposed(by: disposeBag)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        collectionView.rx.contentOffsetAndViewSize
            .bind(to: headerView.parentScrollViewContentOffset)
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        collectionViewLayout.minimumLineSpacing = 1
        collectionViewLayout.minimumInteritemSpacing = 1

        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(FeedCellView.self, forCellWithReuseIdentifier: FeedCellView.reuseIdentifier)
        view.addSubview(collectionView)

        collectionView.addSubview(headerViewContainer)

        headerViewContainer.addSubview(headerView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        headerViewContainer.snp.makeConstraints {
            $0.top.equalTo(collectionView)
            $0.left.right.equalTo(view)
            headerViewContainerHeightConstraint = $0.height.equalTo(100).priority(.medium).constraint.layoutConstraints.first
        }
        headerView.snp.makeConstraints {
            $0.left.right.equalTo(headerViewContainer)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).priority(.high)
            $0.height.greaterThanOrEqualTo(headerViewContainer).priority(.high)
            $0.bottom.equalTo(headerViewContainer.snp.bottom)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let numberOfCols = 2
        let sideWidth = (collectionView.frame.width - CGFloat(numberOfCols - 1)) / CGFloat(numberOfCols)
        collectionViewLayout.itemSize = .init(width: sideWidth, height: sideWidth)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateHeaderSize()
    }

    private func updateHeaderSize() {
        headerViewContainerHeightConstraint?.constant = 100

        headerView.layoutIfNeeded()
        headerViewContainer.layoutIfNeeded()

        headerViewContainerHeightConstraint?.constant = headerView.bounds.height
        collectionViewLayout.headerHeight = headerView.bounds.height
    }
}
