import Foundation
import RxSwift
@testable import foyer

class KeyValueStoreMock: KeyValueStoreType {
    func set<T>(value: T, forKey: String, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) where T : Encodable {
    }

    var getReturnValue: Any?

    func get<T>(_ type: T.Type, forKey: String, dateEncodingStrategy: JSONDecoder.DateDecodingStrategy) -> T? where T : Decodable {
        return getReturnValue as? T
    }

    func removeObject(forKey: String) {
    }
}
