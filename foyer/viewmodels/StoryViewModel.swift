import Foundation
import RxSwift

func storyViewModel(
    disposeBag: DisposeBag,
    viewDidLoad: Observable<Void>,
    story: Observable<Story>,
    closeButtonPressed: Observable<Void>
    ) -> (
    title: Observable<String>,
    coverImage: Observable<UIImage>
    ) {
        closeButtonPressed
            .bind {
                Environment.shared.router.dismiss()
            }
            .disposed(by: disposeBag)

        return (
            title: story.map { $0.title },
            coverImage: .never()
        )
}
