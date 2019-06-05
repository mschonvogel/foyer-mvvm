import UIKit
import RxSwift

func profileHeaderViewModel(
    disposeBag: DisposeBag,
    user: Observable<UserContract?>,
    parentScrollViewContentOffset: Observable<(contentOffset: CGPoint, viewSize: CGSize)>,
    followersPressed: Observable<Void>,
    followingPressed: Observable<Void>
    ) -> (
    name: Observable<String?>,
    followersCount: Observable<String?>,
    followingCount: Observable<String?>,
    userPhoto: Observable<UIImage?>,
    userPhotoScale: Observable<CGFloat>,
    biography: Observable<NSAttributedString?>
    ) {
        let userPhoto: Observable<UIImage?> = user
            .observeOn(MainScheduler.asyncInstance)
            .flatMap { user in
                return Observable<UIImage?>.create { observable in
                    guard let avatarUrl = user?.avatarUrl else {
                        observable.onNext(nil)
                        observable.onCompleted()
                        return Disposables.create()
                    }
                    let dataTask = Environment.shared.foyerClient.loadImage(avatarUrl) { result in
                        switch result {
                        case .success(let image):
                            observable.onNext(image)
                        case .failure:
                            observable.onNext(nil)
                        }
                        observable.onCompleted()
                    }
                    return Disposables.create {
                        dataTask.cancel()
                    }
                }
        }
        let userPhotoScale: Observable<CGFloat> = parentScrollViewContentOffset
            .observeOn(MainScheduler.asyncInstance)
            .map { (offset, viewSize) in
                guard offset.y < 0, viewSize != .zero else { return 1 }
                let delta = 1 - offset.y.truncatingRemainder(dividingBy: viewSize.height) / (viewSize.height * 2)
                return min(delta, 1.18)
        }
        let biographyAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkText,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        return (
            name: user.map { $0?.userName },
            followersCount: user.map { $0?.followersCount.stringValue },
            followingCount: user.map { $0?.followingCount.stringValue },
            userPhoto: userPhoto,
            userPhotoScale: userPhotoScale,
            biography: user.map {
                $0?.biography != nil
                    ? NSAttributedString(string: $0!.biography!.replacedHtmlEntities,
                                         attributes: biographyAttributes)
                    : nil
            }
        )
}
