import XCTest
@testable import foyer

class NetworkerTests: XCTestCase {
    private var networker: Networker!
    private var sessionMock: SessionMock!
    private var sessionDataTaskSpy: SessionDataTaskSpy!
    private var url: URL!
    private var resource: Resource<[String: String]>!

    override func setUp() {
        networker = Networker()
        sessionMock = SessionMock()
        sessionDataTaskSpy = SessionDataTaskSpy()
        url = URL(string: "https://google.com")!
        resource = .init(get: url)

        sessionMock.dataTaskReturnValue = sessionDataTaskSpy

        Environment.reset()
        Environment.shared.urlSession = sessionMock
    }

    func test_dataTask_success() throws {
        let testJson = ["name": "test", "number": "123"]
        let testData = try JSONEncoder().encode(testJson)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        sessionMock.dataTaskCompletionHandlerPayload = (testData, response, nil)

        assertNetworkerResult(resource, expectedResult: .success(testJson))
        sessionDataTaskSpy.assertEquals(cancelCalled: [], resumeCalled: [()])
    }

    func test_dataTask_failure_networking() throws {
        let error = NSError(domain: "test", code: 123, userInfo: nil)
        sessionMock.dataTaskCompletionHandlerPayload = (nil, nil, error)

        assertNetworkerResult(resource, expectedResult: .failure(.networking(error)))
        sessionDataTaskSpy.assertEquals(cancelCalled: [], resumeCalled: [()])
    }

    func test_dataTask_failure_noData() throws {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        sessionMock.dataTaskCompletionHandlerPayload = (nil, response, nil)

        assertNetworkerResult(resource, expectedResult: .failure(.noData))
        sessionDataTaskSpy.assertEquals(cancelCalled: [], resumeCalled: [()])
    }

    func test_dataTask_failure_parsing() throws {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        sessionMock.dataTaskCompletionHandlerPayload = (Data(), response, nil)

        assertNetworkerResult(resource, expectedResult: .failure(.parsing))
        sessionDataTaskSpy.assertEquals(cancelCalled: [], resumeCalled: [()])
    }

    func test_dataTask_failure_unknown_statusCode() throws {
        let response = HTTPURLResponse(url: url, statusCode: 444, httpVersion: nil, headerFields: nil)
        sessionMock.dataTaskCompletionHandlerPayload = (Data(), response, nil)

        assertNetworkerResult(resource, expectedResult: .failure(.unknown))
        sessionDataTaskSpy.assertEquals(cancelCalled: [], resumeCalled: [()])
    }

    func test_dataTask_failure_unknown_responseMissing() throws {
        sessionMock.dataTaskCompletionHandlerPayload = (Data(), nil, nil)

        assertNetworkerResult(resource, expectedResult: .failure(.unknown))
        sessionDataTaskSpy.assertEquals(cancelCalled: [], resumeCalled: [()])
    }

    private func assertNetworkerResult<T: Decodable>(_ resource: Resource<T>, expectedResult: ApiResult<T>) where T:Equatable {
        let exp = expectation(description: "assert-networker-result")
        var networkerResult: ApiResult<T>!

        _ = networker.load(resource) { result in
            networkerResult = result
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.01)
        XCTAssertEqual(networkerResult, expectedResult)
    }
}

