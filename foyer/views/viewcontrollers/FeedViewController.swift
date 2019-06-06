import Foundation
import UIKit
import RxCocoa
import RxSwift

final class FeedViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let collectionView: UICollectionView
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private let reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)

    private var activities = [Activity]()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        let (activitiesLoaded, showError, reloadButtonEnabled) = feedViewModel(
            disposeBag: disposeBag,
            viewDidLoad: rx.viewDidLoad.asObservable(),
            itemSelected: collectionView.rx.itemSelected.asObservable(),
            reloadButtonPressed: reloadBarButtonItem.rx.tap.asObservable()
        )

        activitiesLoaded
            .bind {
                self.activities = $0
            }
            .disposed(by: disposeBag)
        activitiesLoaded
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCellView.reuseIdentifier, cellType: FeedCellView.self)) { (_, activity, cell) in
                cell.story.onNext(activity.story)
            }
            .disposed(by: disposeBag)
        showError
            .bind { message in
                print(message)
            }
            .disposed(by: disposeBag)
        reloadButtonEnabled
            .bind(to:reloadBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }

        navigationItem.rightBarButtonItem = reloadBarButtonItem
        title = "Feed"

        view.backgroundColor = .white

        collectionViewLayout.minimumLineSpacing = 1
        collectionViewLayout.minimumInteritemSpacing = 1

        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(FeedCellView.self, forCellWithReuseIdentifier: FeedCellView.reuseIdentifier)
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let numberOfCols = 1
        let sideWidth = (collectionView.frame.width - CGFloat(numberOfCols - 1)) / CGFloat(numberOfCols)
        collectionViewLayout.itemSize = .init(width: sideWidth, height: sideWidth)
    }
}

extension FeedViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        showDetailViewController(viewControllerToCommit, sender: self)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: collectionView.convert(location, from: view)),
            let cell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }

        let vc = StoryViewController(story: activities[indexPath.item].story)
        vc.preferredContentSize = CGSize(width: 0, height: 360)

        previewingContext.sourceRect = collectionView.convert(cell.frame, to: collectionView.superview!)

        return vc
    }
}
