import Foundation
import XCTest
@testable import foyer

class SessionDataTaskSpy: SessionDataTask {
    private (set) var cancelCalled: [()] = []
    private (set) var resumeCalled: [()] = []

    func cancel() {
        cancelCalled.append(())
    }

    func resume() {
        resumeCalled.append(())
    }
}

extension SessionDataTaskSpy {
    func assertEquals(cancelCalled: [()], resumeCalled: [()]) {
        XCTAssertEqual(self.cancelCalled.count, cancelCalled.count)
        XCTAssertEqual(self.resumeCalled.count, resumeCalled.count)
    }
}
