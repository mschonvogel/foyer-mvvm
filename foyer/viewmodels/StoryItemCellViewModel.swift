import Foundation
import RxSwift

func storyItemCellViewModel(
    disposeBag: DisposeBag,
    item: Observable<Story.Item>
    ) -> (
    Observable<UIImage?>
    ) {
        let imageProperty = PublishSubject<UIImage?>()
        item
            .compactMap { $0.fileUrl }
            .bind {
                _ = Environment.shared.foyerClient.loadImage($0) { result in
                    switch result {
                    case .success(let image):
                        imageProperty.onNext(image)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)

        return (
            imageProperty.asObservable()
        )
}
