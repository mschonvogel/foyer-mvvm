import Foundation
import RxSwift
@testable import foyer

extension Environment {
    static func reset() {
        shared = Environment(
            user: .init(value: nil),
            router: RouterSpy(),
            networker: NetworkerSpy(),
            foyerClient: .mock,
            urlSession: SessionMock(),
            keyValueStore: KeyValueStoreMock()
        )
    }
}
