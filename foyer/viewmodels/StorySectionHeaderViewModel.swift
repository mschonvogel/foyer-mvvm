import UIKit
import RxSwift
import RxCocoa

func storySectionHeaderViewModel(
    disposeBag: DisposeBag,
    isEditing: BehaviorRelay<Bool>,
    section: Observable<Story.Section>
    ) -> (
    title: Observable<NSAttributedString?>,
    titleIsHidden: Observable<Bool>,
    titleBackgroundColor: Observable<UIColor>,
    titleTextContainerInsets: Observable<UIEdgeInsets>,
    content: Observable<NSAttributedString?>,
    contentIsHidden: Observable<Bool>,
    contentBackgroundColor: Observable<UIColor>,
    contentTextContainerInsets: Observable<UIEdgeInsets>
    ) {
        return (
            title: section.map { $0.title != nil && !$0.title!.isEmpty
                ? NSAttributedString(string: $0.title!, attributes: storySectionHeaderTitleAttributes)
                : nil
            },
            titleIsHidden: .combineLatest(section, isEditing) { (section, isEditing) in
                !isEditing && (section.title == nil || section.title!.trimmingCharacters(in: .whitespaces).isEmpty)
            },
            titleBackgroundColor: isEditing.map { $0 ? .groupTableViewBackground : .white },
            titleTextContainerInsets: isEditing.map { $0 ? UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) : .zero },
            content: section.map { $0.text != nil
                ? NSAttributedString(string: $0.text!, attributes: storySectionHeaderContentAttributes)
                : nil
            },
            contentIsHidden: .combineLatest(section, isEditing) { (section, isEditing) in
                !isEditing && (section.text == nil || section.text!.trimmingCharacters(in: .whitespaces).isEmpty)
            },
            contentBackgroundColor: isEditing.map { $0 ? .groupTableViewBackground : .white },
            contentTextContainerInsets: isEditing.map { $0 ? UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) : .zero }
        )
}
