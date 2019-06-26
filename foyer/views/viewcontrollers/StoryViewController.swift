import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class StoryViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var story: Story
    private let editEnabled = BehaviorRelay<Bool>(value: true)

    private let layout = BalancedLayout()
    private let collectionView: UICollectionView
    private let headerView = StoryHeaderView()
    private let closeButton = UIButton(type: .infoDark)
    private let editButton = UIButton()

    init(story: Story) {
        self.story = story

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)

        let (sections, isEditing) = storyViewModel(
            disposeBag: disposeBag,
            viewDidLoad: rx.viewDidLoad.asObservable(),
            story: .of(story),
            closeButtonPressed: closeButton.rx.tap.asObservable(),
            editButtonPressed: editButton.rx.tap.asObservable()
        )

        isEditing
            .bind(to: editEnabled)
            .disposed(by: disposeBag)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<StorySectionModel>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            decideViewTransition: { _, _, _ in .animated },
            configureCell: { (dataSource, collectionView, indexPath, storyItem) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryItemCellView.reuseIdentifier, for: indexPath) as! StoryItemCellView
                let item = story.sections[indexPath.section].items[indexPath.item]
                cell.configure(with: item)

                return cell
        },
            configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
                if kind == UICollectionView.elementKindSectionHeader {
                    let section = story.sections[indexPath.section]
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                 withReuseIdentifier: StorySectionHeaderView.reuseIdentifier,
                                                                                 for: indexPath) as! StorySectionHeaderView
                    header.configure(with: section, isEditing: self.editEnabled)
                    return header
                }
                if kind == UICollectionView.elementKindSectionFooter {
                    return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                           withReuseIdentifier: StorySectionFooterView.reuseIdentifier,
                                                                           for: indexPath)
                }
                fatalError("missing view")
        },

            moveItem: { (dataSource, sourceIndexPath, destinationIndexPath) in

        },
            canMoveItemAtIndexPath: { (dataSource, indexPath) -> Bool in
                return true
        }
        )

        sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
//        collectionView.rx.prefetchItems
//            .bind { print($0) }
//            .disposed(by: disposeBag)

        headerView.story.onNext(story)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        layout.preferredRowSize = 150
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        collectionView.register(StoryItemCellView.self, forCellWithReuseIdentifier: StoryItemCellView.reuseIdentifier)
        collectionView.register(StorySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StorySectionHeaderView.reuseIdentifier)
        collectionView.register(StorySectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: StorySectionFooterView.reuseIdentifier)
//        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.backgroundColor = .white
        collectionView.dragInteractionEnabled = false
        collectionView.reorderingCadence = .slow
        view.addSubview(collectionView)
        collectionView.addSubview(headerView)

        let headerViewContainer = UIView()
        collectionView.addSubview(headerViewContainer)

        headerViewContainer.addSubview(headerView)

        closeButton.tintColor = .white
        view.addSubview(closeButton)

        editButton.setTitle("Edit", for: .normal)
        view.addSubview(editButton)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        headerViewContainer.snp.makeConstraints {
            $0.top.equalTo(collectionView)
            $0.left.right.equalTo(view)
            $0.height.equalTo(view).multipliedBy(0.7).priority(.medium)
        }
        headerView.snp.makeConstraints {
            $0.left.right.equalTo(headerViewContainer)
            $0.top.equalTo(view.snp.top).priority(.high)
            $0.height.greaterThanOrEqualTo(headerViewContainer).priority(.high)
            $0.bottom.equalTo(headerViewContainer.snp.bottom)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        editButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layout.storyCoverHeight = view.frame.height * 0.7
    }
}

//extension StoryViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return story.sections.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return story.sections[section].items.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryItemCellView.reuseIdentifier, for: indexPath) as! StoryItemCellView
//        let item = story.sections[indexPath.section].items[indexPath.item]
//        cell.configure(with: item)
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionHeader {
//            let section = story.sections[indexPath.section]
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
//                                                                         withReuseIdentifier: StorySectionHeaderView.reuseIdentifier,
//                                                                         for: indexPath) as! StorySectionHeaderView
//            header.section.onNext(section)
//            return header
//        }
//        if kind == UICollectionView.elementKindSectionFooter {
//            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
//                                                                   withReuseIdentifier: StorySectionFooterView.reuseIdentifier,
//                                                                   for: indexPath)
//        }
//        fatalError("missing view")
//    }
//}

extension StoryViewController: BalancedLayoutDelegate {
    func sectionIsOfTypeFullWidth(section: Int) -> Bool {
        return story.sections[section].type == .fullscreen
    }

    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, preferredSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let item = story.sections[indexPath.section].items[indexPath.item]
        return CGSize(width: item.width, height: item.height)
    }

    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, itemShouldFillRowAtIndexPath indexPath: IndexPath) -> Bool {
        let item = story.sections[indexPath.section].items[indexPath.item]
        return item.fillRow == true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let section = story.sections[section]
        return StorySectionHeaderView.calculateSize(viewWidth: collectionView.bounds.width, section: section, isEditing: editEnabled.value)
    }
}

extension StoryViewController: HiddenTabBarViewController {}

extension StoryViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = story.sections[indexPath.section].items[indexPath.item]
        let itemProvider = NSItemProvider(object: item.objectId as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item

        return [dragItem]
    }
}

extension StoryViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        guard let dragItem = coordinator.session.localDragSession?.items.first else { return }
        guard let droppedItem = dragItem.localObject as? Story.Item else { return }

        //        collectionView.performBatchUpdates({
        //            self.items.remove(at: sourceIndexPath.row)
        //            self.items.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
        //            collectionView.deleteItems(at: [sourceIndexPath])
        //            collectionView.insertItems(at: [dIndexPath])
        //        })
        //        let section = story.sections[destinationIndexPath.section]
        //        story.sections[destinationIndexPath.section].items.remove(at: section.items.firstIndex(of: droppedItem)!)
        //        story.sections[destinationIndexPath.section].items.insert(droppedItem, at: destinationIndexPath.item)

        coordinator.drop(dragItem, toItemAt: destinationIndexPath)
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard collectionView.hasActiveDrag else { return .init(operation: .forbidden) }

        return .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    //    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
    //
    //    }
}
