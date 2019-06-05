import Foundation
import UIKit

enum ApiResult<T: Equatable>: Equatable {
    case success(T)
    case failure(ApiError)
}

enum HttpMethod<Body: Encodable> {
    case get
    case post(Body)
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}

private extension URLResponse {
    var httpStatusCode: Int {
        // this cast will fail only if we don't use HTTP.
        let response = self as! HTTPURLResponse
        return response.statusCode
    }
}

struct Resource<A> {
    var urlRequest: URLRequest
    let parse: (Data) throws -> A
}

extension Resource where A: Decodable {
    init(get url: URL) {
        self.urlRequest = URLRequest(url: url)
        self.parse = { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(A.self, from: data)
        }
    }

    init<Body: Encodable>(url: URL, method: HttpMethod<Body>) {
        urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.method
        switch method {
        case .get: ()
        case .post(let body):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            self.urlRequest.httpBody = try! encoder.encode(body)
        }
        self.parse = { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(A.self, from: data)
        }
    }
}

extension Resource where A == UIImage {
    init(get url: URL) {
        self.urlRequest = URLRequest(url: url)
        self.parse = { data in
            guard let image = UIImage(data: data) else {
                throw ApiError.parsing
            }
            return image
        }
    }
}

extension Resource: Equatable {
    static func == (lhs: Resource<A>, rhs: Resource<A>) -> Bool {
        return lhs.urlRequest == rhs.urlRequest
    }
}

protocol SessionDataTask {
    func resume()
    func cancel()
}

extension URLSessionDataTask: SessionDataTask {}

protocol Session {
    func loadDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask
}

extension URLSession: Session {
    func loadDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask {
        return dataTask(with: request, completionHandler: completionHandler)
    }
}

protocol NetworkerContract {
    func load<A>(_ resource: Resource<A>, completion: @escaping (ApiResult<A>) -> ()) -> SessionDataTask
}

struct Networker: NetworkerContract {
    func load<A>(_ resource: Resource<A>, completion: @escaping (ApiResult<A>) -> ()) -> SessionDataTask {
        let task = Environment.shared.urlSession.loadDataTask(with: resource.urlRequest) { data, response, networkingError in
            DispatchQueue.main.async {
                if let error = networkingError as NSError? {
                    return completion(.failure(.networking(error)))
                }
                guard let data = data else {
                    return completion(.failure(.noData))
                }
                let statusCode = response?.httpStatusCode ?? -1

                switch statusCode {
                case 200...299:
                    do {
                        try completion(.success(resource.parse(data)))
                    } catch {
                        print(error)
                        completion(.failure(.parsing))
                    }
                // Todo: handle more errors...
                default:
                    print(resource.urlRequest.url)
                    print(statusCode)
                    print(String(data: data, encoding: .utf8))
                    completion(.failure(.unknown))
                }
            }
        }
        task.resume()

        return task
    }
}

enum ApiError: Error, Equatable {
    case networking(NSError)
    case parsing
    case noData
    case unknown

    var localizedDescription: String {
        switch self {
        case .networking(let error):
            return error.localizedDescription
        case .parsing:
            return "parsing error"
        case .noData:
            return "no data error"
        case .unknown:
            return "unknown error"
        }
    }
}
