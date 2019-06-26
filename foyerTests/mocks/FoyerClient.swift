import Foundation
import RxSwift
@testable import foyer

extension FoyerClient {
    static let mock = FoyerClient(
        accountLogin: { (_, completion) in
            completion(
                .success(.mock)
            )
        },
        getFeatured: { completion in
            completion(
                .success([Story.mock])
            )
        },
        getFeed: { (page, completion) in
            completion(
                .success([Activity.mock])
            )
        },
        getUser: { (userName, completion) in
            completion(
                .success(User.mock)
            )
        },
        getAppUser: { completion in
            completion(
                .success(AppUser.mock)
            )
        },
        loadImage: { (url, completion) -> SessionDataTask in
            completion(
                .success(.mock)
            )
            return SessionDataTaskSpy()
        }
    )
}
