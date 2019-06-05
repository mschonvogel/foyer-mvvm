import UIKit
import RxSwift

struct FoyerClient {
    var accountLogin = accountLogin(payload:completion:)
    var getFeatured = getFeaturedStories(completion:)
    var getFeed = getFeed(page:completion:)
    var getUser = getUser(userName:completion:)
    var getAppUser = getAppUser(completion:)

    var loadImage = loadImage(url:completion:)

    enum Router {
        case login
        case feed(Int)
        case storiesFeatured
        case user(String)
        case appUser

        private var path: String {
            switch self {
            case .login:
                return "login"
            case .feed(let page):
                return "feed?page=\(page)"
            case .storiesFeatured:
                return "stories/featured"
            case .user(let userName):
                return "user/\(userName)"
            case .appUser:
                return "user"
            }
        }

        var url: URL {
            return URL(string: "https://api.foyer.co/\(path)")!
        }
    }
}

private func accountLogin(payload: LoginRequestPayload, completion: @escaping (ApiResult<AppUser>) -> Void) {
    let resource = Resource<AppUser>(url: FoyerClient.Router.login.url, method: .post(payload))
    _ = load(resource) { result in
        if case .success(let user) = result {
            Environment.shared.user.onNext(user)
        }
        completion(result)
    }
}

private func getFeed(page: Int, completion: @escaping (ApiResult<[Activity]>) -> Void) {
    let resource = Resource<[Activity]>(get: FoyerClient.Router.feed(page).url)
    _ = load(resource, completion: completion)
}

private func getFeaturedStories(completion: @escaping (ApiResult<[Story]>) -> Void) {
    let resource = Resource<[Story]>(get: FoyerClient.Router.storiesFeatured.url)
    _ = load(resource, completion: completion)
}

private func getUser(userName: String, completion: @escaping (ApiResult<User>) -> Void) {
    let resource = Resource<User>(get: FoyerClient.Router.user(userName).url)
    _ = load(resource, completion: completion)
}

private func getAppUser(completion: @escaping (ApiResult<AppUser>) -> Void) {
    let resource = Resource<AppUser>(get: FoyerClient.Router.appUser.url)
    _ = load(resource, completion: completion)
}

private func loadImage(url: URL, completion: @escaping (ApiResult<UIImage>) -> Void) -> SessionDataTask {
    let resource = Resource<UIImage>(get: url)
    return Environment.shared.networker.load(resource, completion: completion)
}

private func load<A>(_ resource: Resource<A>, completion: @escaping (ApiResult<A>) -> ()) -> SessionDataTask {
    var resource = resource
    resource.urlRequest.setValue("mIQT8FDbMsvb6eZW63nuOilA9eZqpwEz", forHTTPHeaderField: "api-token")
    resource.urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

    if let userToken = (try? Environment.shared.user.value())?.token {
        resource.urlRequest.setValue(userToken, forHTTPHeaderField: "user-token")
    }

    return Environment.shared.networker.load(resource, completion: completion)
}
