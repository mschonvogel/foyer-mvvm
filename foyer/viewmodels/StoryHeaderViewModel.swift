import Foundation
import RxSwift

func storyHeaderViewModel(
    disposeBag: DisposeBag,
    story: Observable<Story>,
    authorNameButtonPressed: Observable<Void>
    ) -> (
    title: Observable<String>,
    authorName: Observable<String>,
    coverImage: Observable<UIImage?>
    ) {
        authorNameButtonPressed
            .withLatestFrom(story)
            .bind { story in
                Environment.shared.router.presentUser(story.author.userName)
            }
            .disposed(by: disposeBag)

        let coverImageProperty = PublishSubject<UIImage?>()

        story
            .compactMap { $0.cover?.fileUrl }
            .bind {
                _ = Environment.shared.foyerClient.loadImage($0) { result in
                    switch result {
                    case .success(let image):
                        coverImageProperty.onNext(image)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        return (
            title: story.map { $0.title },
            authorName: story.map { $0.author.userName },
            coverImage: coverImageProperty.asObservable()
        )
}
