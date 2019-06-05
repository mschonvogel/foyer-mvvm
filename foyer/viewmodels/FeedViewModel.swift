import Foundation
import RxSwift

func feedViewModel(
    disposeBag: DisposeBag,
    viewDidLoad: Observable<Void>,
    itemSelected: Observable<IndexPath>,
    reloadButtonPressed: Observable<Void>
    ) -> (
    activitiesLoaded: Observable<[Activity]>,
    showError: Observable<String>,
    reloadButtonEnabled: Observable<Bool>
    ) {
        let activitiesLoaded = PublishSubject<[Activity]>()
        let showError = PublishSubject<String>()
        let isLoading = BehaviorSubject<Bool>(value: false)

        Observable<AppUser?>
            .merge(
                reloadButtonPressed.withLatestFrom(Environment.shared.user),
                viewDidLoad.withLatestFrom(Environment.shared.user),
                Environment.shared.user
            )
            .debounce(.milliseconds(400), scheduler: MainScheduler.asyncInstance)
            .flatMap { user -> Observable<ApiResult<[Activity]>> in
                isLoading.onNext(true)
                return Observable.create { observer in
                    if user != nil {
                        Environment.shared.foyerClient.getFeed(1) { result in
                            observer.onNext(result)
                            observer.onCompleted()
                        }
                    } else {
                        // Logged out users cannot get the feed.
                        // Use featured stories contained in activity instead
                        Environment.shared.foyerClient.getFeatured { result in
                            switch result {
                            case .success(let stories):
                                let activities = stories.map {
                                    Activity(createdAt: $0.createdAt, type: .new, author: $0.author, story: $0)
                                }
                                observer.onNext(.success(activities))
                            case .failure(let error):
                                observer.onNext(.failure(error))
                            }
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .bind { result in
                switch result {
                case .success(let activities):
                    activitiesLoaded.onNext(activities)
                case .failure(let error):
                    showError.onNext(error.localizedDescription)
                }
                isLoading.onNext(false)
            }
            .disposed(by: disposeBag)

        itemSelected
            .withLatestFrom(activitiesLoaded) { (indexPath, activities) -> Activity in
                activities[indexPath.item]
            }
            .bind { activity in
                Environment.shared.router.presentStory(activity.story)
            }
            .disposed(by: disposeBag)

        return (
            activitiesLoaded: activitiesLoaded,
            showError: showError,
            reloadButtonEnabled: isLoading.map { !$0 }
        )
}
