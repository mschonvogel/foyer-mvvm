import Foundation

protocol KeyValueStoreType: class {
    func set<T: Encodable>(value: T, forKey: String, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy)
    func get<T: Decodable>(_ type: T.Type, forKey: String, dateEncodingStrategy: JSONDecoder.DateDecodingStrategy) -> T?
    func removeObject(forKey: String)
}

extension UserDefaults: KeyValueStoreType {
    func set<T: Encodable>(value: T, forKey: String, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .millisecondsSince1970) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy

        set(try! encoder.encode(value), forKey: forKey)
    }

    func get<T: Decodable>(_ type: T.Type, forKey: String, dateEncodingStrategy: JSONDecoder.DateDecodingStrategy = .millisecondsSince1970) -> T? {
        guard let data = data(forKey: forKey) else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateEncodingStrategy

        return try! decoder.decode(T.self, from: data)
    }
}
