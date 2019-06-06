import Foundation
import RxSwift

func storyViewModel(
    disposeBag: DisposeBag,
    viewDidLoad: Observable<Void>,
    story: Observable<Story>,
    authorNameButtonPressed: Observable<Void>,
    closeButtonPressed: Observable<Void>
    ) -> (
    title: Observable<String>,
    authorName: Observable<String>,
    coverImage: Observable<UIImage>
    ) {
        closeButtonPressed
            .bind {
                Environment.shared.router.dismiss()
            }
            .disposed(by: disposeBag)
        authorNameButtonPressed
            .withLatestFrom(story)
            .bind { story in
                Environment.shared.router.presentUser(story.author)
            }
            .disposed(by: disposeBag)
        return (
            title: story.map { $0.title },
            authorName: story.map { $0.author.userName },
            coverImage: .never()
        )
}
