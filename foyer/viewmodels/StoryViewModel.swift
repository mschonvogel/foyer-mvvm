import Foundation
import RxSwift
import RxDataSources

extension Story.Item: IdentifiableType {
    typealias Identity = String
    var identity: Identity { return objectId }
}

struct StorySectionModel: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = Story.Item

    var items: [Story.Item]
    var title: String?
    var text: String?
    var internId: String

    init(original: StorySectionModel, items: [Story.Item]) {
        self = original
        self.items = items
    }

    init(section: Story.Section) {
        self.items = section.items
        self.title = section.title
        self.text = section.text
        self.internId = section.internId
    }

    var identity: String { return internId }
}

func storyViewModel(
    disposeBag: DisposeBag,
    viewDidLoad: Observable<Void>,
    story: Observable<Story>,
    closeButtonPressed: Observable<Void>,
    editButtonPressed: Observable<Void>
    ) -> (
    sections: Observable<[StorySectionModel]>,
    isEditing: Observable<Bool>
    ) {
        closeButtonPressed
            .bind {
                Environment.shared.router.dismiss()
            }
            .disposed(by: disposeBag)
        var isEditing = false
        return (
            sections: story.map { $0.sections.map(StorySectionModel.init) },
            isEditing: editButtonPressed.map {
                isEditing = !isEditing
                return isEditing
            }
        )
}
