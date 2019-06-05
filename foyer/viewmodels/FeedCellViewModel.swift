import UIKit
import RxSwift
import RxCocoa

func feedCellViewModel(
    disposeBag: DisposeBag,
    story: Observable<Story>,
    prepareForReuse: Observable<Void>
    ) -> (
    title: Observable<String?>,
    authorName: Observable<String?>,
    coverImage: Observable<UIImage?>
    ) {
        let title: Observable<String?> = .merge(
            prepareForReuse.map { nil },
            story.map { $0.title }
        )
        let authorName: Observable<String?> = .merge(
            prepareForReuse.map { nil },
            story.map { _ in "Malte" }
        )

        let coverImageProperty = PublishSubject<UIImage?>()
        var dataTask: SessionDataTask?

        story
            .compactMap { $0.cover?.fileUrl }
            .bind {
                dataTask = Environment.shared.foyerClient.loadImage($0) { result in
                    switch result {
                    case .success(let image):
                        coverImageProperty.onNext(image)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)

        let coverImage: Observable<UIImage?> = .merge(
            coverImageProperty,
            prepareForReuse.map { nil }
        )

        prepareForReuse
            .bind {
                dataTask?.cancel()
            }
            .disposed(by: disposeBag)

        return (
            title: title,
            authorName: authorName,
            coverImage: coverImage
        )
}
