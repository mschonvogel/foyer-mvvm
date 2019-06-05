import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxOptional

func appUserViewModel(
    disposeBag: DisposeBag,
    viewDidLoad: Observable<Void>
    ) -> (
    user: Observable<UserContract?>,
    stories: Observable<[Story]>,
    showError: Observable<String>
    ) {
        let storiesPublish = PublishSubject<[Story]>()
        let showError = PublishSubject<String>()

        Environment.shared.foyerClient.getFeatured { result in
            switch result {
            case .success(let stories):
                storiesPublish.onNext(stories)
            case .failure(let error):
                showError.onNext(error.localizedDescription)
            }
        }

        return (
            user: Environment.shared.user.map { $0 },
            stories: storiesPublish,
            showError: showError
        )
}
