import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxOptional

func userViewModel(
    disposeBag: DisposeBag,
    userName: Observable<String>,
    viewDidLoad: Observable<Void>,
    itemSelected: Observable<IndexPath>
    ) -> (
    user: Observable<UserContract?>,
    stories: Observable<[Story]>,
    recalculateHeaderSize: Observable<Void>,
    showError: Observable<String>
    ) {
        let userPublish = PublishSubject<UserContract?>()
        let storiesPublish = PublishSubject<[Story]>()
        let errorPublish = PublishSubject<String>()

        viewDidLoad
            .withLatestFrom(userName)
            .bind { userName in
                Environment.shared.foyerClient.getUser(userName) { result in
                    switch result {
                    case .success(let user):
                        userPublish.onNext(user)
                        storiesPublish.onNext(user.stories ?? [])
                    case .failure(let error):
                        errorPublish.onNext(error.localizedDescription)
                    }
                }
            }
            .disposed(by: disposeBag)
        itemSelected
            .withLatestFrom(storiesPublish) { (indexPath, stories) -> Story in
                stories[indexPath.item]
            }
            .bind { story in
                Environment.shared.router.presentStory(story)
            }
            .disposed(by: disposeBag)

        return (
            user: userPublish,
            stories: storiesPublish,
            recalculateHeaderSize: userPublish
                .debounce(.milliseconds(5), scheduler: MainScheduler.asyncInstance)
                .map { _ in },
            showError: errorPublish
        )
}
