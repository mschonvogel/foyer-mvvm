import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxOptional

func appUserViewModel(
    disposeBag: DisposeBag,
    viewDidLoad: Observable<Void>,
    itemSelected: Observable<IndexPath>,
    logoutButtonPressed: Observable<Void>
    ) -> (
    user: Observable<UserContract?>,
    stories: Observable<[Story]>,
    recalculateHeaderSize: Observable<Void>,
    showError: Observable<String>
    ) {
        let storiesPublish = PublishSubject<[Story]>()
        let errorPublish = PublishSubject<String>()

        Environment.shared.foyerClient.getFeatured { result in
            switch result {
            case .success(let stories):
                storiesPublish.onNext(stories)
            case .failure(let error):
                errorPublish.onNext(error.localizedDescription)
            }
        }
        itemSelected
            .withLatestFrom(storiesPublish) { (indexPath, stories) -> Story in
                stories[indexPath.item]
            }
            .bind { story in
                Environment.shared.router.presentStory(story)
            }
            .disposed(by: disposeBag)
        logoutButtonPressed
            .bind {
                Environment.shared.logout()
            }
            .disposed(by: disposeBag)

        return (
            user: Environment.shared.user.map { $0 },
            stories: storiesPublish,
            recalculateHeaderSize: Environment.shared.user
                .throttle(.milliseconds(5), scheduler: MainScheduler.asyncInstance)
                .map { _ in },
            showError: errorPublish
        )
}
