import Foundation
@testable import foyer

class NetworkerSpy: NetworkerContract {
    private (set) var loadCalled: [Any] = []

    func load<A>(_ resource: Resource<A>, completion: @escaping (ApiResult<A>) -> ()) -> SessionDataTask {
        loadCalled.append(resource)
        return SessionDataTaskSpy()
    }
}
