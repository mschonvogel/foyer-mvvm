import Foundation
@testable import foyer

class SessionMock: Session {
    var dataTaskCompletionHandlerPayload: (data: Data?, response: URLResponse?, error: Error?)?
    var dataTaskReturnValue: SessionDataTask?

    func loadDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionDataTask {
        completionHandler(
            dataTaskCompletionHandlerPayload?.data,
            dataTaskCompletionHandlerPayload?.response,
            dataTaskCompletionHandlerPayload?.error
        )

        return dataTaskReturnValue!
    }
}
