import Foundation
import RxSwift

struct Environment {
    var user: BehaviorSubject<AppUser?>
    var router: RouterContract
    var networker: NetworkerContract
    var foyerClient: FoyerClient
    var urlSession: Session
    var keyValueStore: KeyValueStoreType

    init(
        user: BehaviorSubject<AppUser?> = .init(value: nil),
        router: RouterContract = Router(),
        networker: NetworkerContract = Networker(),
        foyerClient: FoyerClient = .init(),
        urlSession: Session = URLSession.shared,
        keyValueStore: KeyValueStoreType = UserDefaults.standard
        ) {
        self.user = user
        self.router = router
        self.networker = networker
        self.foyerClient = foyerClient
        self.urlSession = urlSession
        self.keyValueStore = keyValueStore
    }

    func saveEnvironment(environment env: Environment = .shared) {
        if let currentUser = try? user.value() {
            keyValueStore.set(value: currentUser, forKey: "currentUser", dateEncodingStrategy: .millisecondsSince1970)
        } else {
            keyValueStore.removeObject(forKey: "currentUser")
        }
    }

    func start() {
        if let currentUser = keyValueStore.get(AppUser.self, forKey: "currentUser", dateEncodingStrategy: .millisecondsSince1970) {
            user.onNext(currentUser)

            foyerClient.getAppUser { result in
                switch result {
                case .success(let appUser):
                    self.user.onNext(appUser)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

extension Environment {
    #if DEBUG
    static var shared = Environment()
    #else
    static let shared = Environment()
    #endif
}
